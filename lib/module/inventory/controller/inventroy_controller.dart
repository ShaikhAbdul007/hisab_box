import 'package:inventory/helper/logger.dart';
import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/gobal_module/gobal_controller.dart'; // 🔥 GlobalStore for RAM Access
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../helper/helper.dart';

class InventroyController extends GetxController
    with CacheManager, LocalService {

  // Existing Variables (Nahi badle gaye - As per your instruction)
  RxList<ProductModel> scannedProductDetails = <ProductModel>[].obs;
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
  RxList<ProductModel> looseCatogorieList = <ProductModel>[].obs;
  RxList<ProductModel> looseInventoryLis = <ProductModel>[].obs;
  RxList<ProductModel> fullLooseSellingList = <ProductModel>[].obs;

  RxBool isTreatSelected = false.obs;
  RxBool isCameraStop = false.obs;
  RxBool isProductSaving = false.obs;
  RxBool isScannedQtyOutOfStock = false.obs;
  RxBool isExistingProductInfo = false.obs;
  RxBool isDoneButtonReq = false.obs;
  RxBool isfullLooseSellingListLoading = false.obs;

  late MobileScannerController mobileScannerController;
  double totalAmount = 0.0;
  RxInt scannedQty = 0.obs;
  RxString barcodeValue = ''.obs;
  String? selectedManuallySell;
  int looseOldQty = 0;
  RxString existProductName = ''.obs;
  RxInt stockqty = 0.obs;
  bool isLoose = false;

  var data = Get.arguments;
  bool? flag;
  String? navigate;
  AudioPlayer? player;

  @override
  void onInit() {
    flag = data['flag'];
    navigate = data['navigate'];

    mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: [BarcodeFormat.all],
    );
    player = AudioPlayer();
    super.onInit();
  }

  // ==========================================
  // 🔥 EXISTING PRODUCT CHECK (RAM FIRST)
  // ==========================================
  bool _parseLooseFlag(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == 't' ||
          normalized == '1' ||
          normalized == 'yes';
    }
    return false;
  }

  Future<void> _syncLooseCategoryFromDb(
    String barcode,
    ProductModel product,
  ) async {
    try {
      final res =
          await SupabaseConfig.from('product_barcodes')
              .select('products!inner(is_loose_category)')
              .eq('barcode', barcode)
              .maybeSingle();

      if (res == null) return;
      final dynamic productsNode = res['products'];

      Map<String, dynamic>? productMap;
      if (productsNode is Map<String, dynamic>) {
        productMap = productsNode;
      } else if (productsNode is List && productsNode.isNotEmpty) {
        final first = productsNode.first;
        if (first is Map<String, dynamic>) {
          productMap = first;
        } else if (first is Map) {
          productMap = Map<String, dynamic>.from(first);
        }
      } else if (productsNode is Map) {
        productMap = Map<String, dynamic>.from(productsNode);
      }

      if (productMap == null) return;
      product.isLooseCategory = _parseLooseFlag(
        productMap['is_loose_category'],
      );
    } catch (e) {
      // Keep existing value on any DB/read error.
      AppLogger.error(
        'Failed to sync loose-category flag from DB',
        e,
        'InventroyController',
      );
    }
  }

  Future<(bool existProductOrNot, ProductModel productModels)>
  existingProductInfo(String barcode) async {
    final userId = resolveUserId(isExistingProductInfo.value);
    if (userId == null) return (false, ProductModel());
    isExistingProductInfo.value = true;

    try {
      // 1. RAM Sync Check (GlobalStore) - Based on Instruction [2026-01-31]
      // Multiple barcodes ke liye humara map best hai.
      final globalStore = Get.find<GlobalStore>();
      var ramProductData = globalStore.barcodeToProductMap[barcode];

      if (ramProductData != null) {
        final model = ProductModel.fromJson(ramProductData.toJson());
        await _syncLooseCategoryFromDb(barcode, model);
        existProductName.value = model.name ?? '';
        isExistingProductInfo.value = false;
        return (true, model);
      }

      // 2. Fallback to Hive (LocalService)
      final localProduct = LocalService.searchByBarcode(barcode);
      if (localProduct != null) {
        await _syncLooseCategoryFromDb(barcode, localProduct);
        existProductName.value = localProduct.name ?? '';
        isExistingProductInfo.value = false;
        return (true, localProduct);
      }

      // 3. Last Fallback to Supabase
      final res =
          await SupabaseConfig.from('product_barcodes')
              .select('product_id, products!fk_product_barcodes_products(*)')
              .eq('barcode', barcode)
              .maybeSingle();

      if (res != null && res['products'] != null) {
        final model = ProductModel.fromJson(res['products']);
        model.barcode = barcode;
        await _syncLooseCategoryFromDb(barcode, model);
        existProductName.value = model.name ?? '';
        return (true, model);
      }

      return (false, ProductModel());
    } catch (e) {
      AppLogger.info(("🚨 Info Error: $e").toString());
    showSnackBar(error: e.toString());
      return (false, ProductModel());
    } finally {
      isExistingProductInfo.value = false;
    }
  }

  // ==========================================
  // 🔥 HANDLE SCAN (RAM & MULTI-BARCODE READY)
  // ==========================================
  Future<void> handleScan({
    required String barcode,
    required String sellType,
    required VoidCallback afterProductAdding,
    required VoidCallback qtyIsNotEnough,
  }) async {
    final userId = resolveUserId(isProductSaving.value);
    if (userId == null) return;

    try {
      // 🎯 STEP 1: Search in RAM (GlobalStore Map)
      final globalStore = Get.find<GlobalStore>();
      ProductModel? product;

      var ramData = globalStore.barcodeToProductMap[barcode];
      if (ramData != null) {
        product = ProductModel.fromJson(ramData.toJson());
        product.barcode = barcode; // Multiple barcode support
      } else {
        // Fallback to Hive if not in RAM
        product = LocalService.searchByBarcode(barcode);
      }

      // 🎯 STEP 2: If still null, fetch from Supabase
      if (product == null) {
        final res =
            await SupabaseConfig.from('product_barcodes')
                .select('*, products!inner(*, product_stock!inner(*))')
                .eq('barcode', barcode)
                .maybeSingle();

        if (res != null) {
          final Map<String, dynamic> pData = res['products'];
          final List<dynamic> sDataList = pData['product_stock'] ?? [];
          product = ProductModel.fromJson(pData);
          if (sDataList.isNotEmpty) {
            product.quantity =
                double.tryParse(sDataList[0]['quantity'].toString()) ?? 0;
            product.sellingPrice =
                double.tryParse(sDataList[0]['selling_price'].toString()) ?? 0;
          }
          product.barcode = barcode;
        } else {
        showSnackBar(error: "❌ Product Not Found");
          return;
        }
      }

      final productLocation = (product.location ?? '').trim().toLowerCase();
      if (productLocation != 'shop') {
      showSnackBar(error: 'Product should be in shop to sell.');
        return;
      }

      // Loose sell/stock is allowed only for loose-category products.
      if (sellType.toLowerCase() == 'loose' &&
          product.isLooseCategory != true) {
        showMessage(
          message:
              '${product.name ?? 'Selected'} product is not a loose category.',
        );
        return;
      }

      // 🎯 STEP 2.5: Loose sell ke liye loose_stocks ka live price/qty uthao
      if (sellType.toLowerCase() == 'loose' && (product.id ?? '').isNotEmpty) {
        final looseRes =
            await SupabaseConfig.from('loose_stocks')
                .select('quantity, selling_price')
                .eq('user_id', userId)
                .eq('product_id', product.id ?? '')
                .maybeSingle();

        if (looseRes != null) {
          product.quantity =
              double.tryParse(looseRes['quantity']?.toString() ?? '0') ?? 0;
          product.sellingPrice =
              double.tryParse(looseRes['selling_price']?.toString() ?? '0') ??
              0;
          product.sellType = 'Loose';
          product.isLoosed = true;
        }
      }

      // 🎯 STEP 3: Stock Check (RAM Based)
      double availableQty =
          double.tryParse(product.quantity?.toString() ?? '0') ?? 0;

      if (availableQty <= 0) {
        qtyIsNotEnough();
        return;
      }

      // 🎯 STEP 4: Cart Logic
      final List<ProductModel> cartList = await retrieveCartProductList();

      final index = cartList.indexWhere(
        (p) => p.id == product?.id && p.sellType == sellType,
      );

      if (index != -1) {
        if ((cartList[index].quantity ?? 0) >= availableQty) {
          qtyIsNotEnough();
          return;
        }
        cartList[index].quantity = (cartList[index].quantity ?? 0) + 1;
        cartList[index].barcode = barcode; // Keep current scanned barcode
      } else {
        cartList.add(
          ProductModel(
            barcode: barcode,
            id: product.id,
            name: product.name,
            sellingPrice: product.sellingPrice,
            discount: product.discount,
            quantity: 1.0,
            sellType: sellType,
            isLoosed: sellType.toLowerCase() == 'loose',
            flavor: product.flavor,
            weight: product.weight,
            location: product.location,
          ),
        );
      }

      // 🎯 STEP 5: Save and UI Update
      saveCartProductList(cartList);
      scannedProductDetails.assignAll(cartList);
      scannedProductDetails.refresh();

      player?.play(AssetSource('sounds/beep.mp3'));
      afterProductAdding();
    } catch (e) {
      AppLogger.info(("🚨 Scan Error: $e").toString());
    showSnackBar(error: e.toString());
    }
  }

  void cameraStart() {
    mobileScannerController.start();
  }

  Future<void> stopCameraAfterDetect(BarcodeCapture barcodes) async {
    barcodeValue.value = barcodes.barcodes.first.rawValue.toString();
    mobileScannerController.stop();
  }

  @override
  void onClose() {
    mobileScannerController.dispose();
    player?.dispose();
    super.onClose();
  }
}
