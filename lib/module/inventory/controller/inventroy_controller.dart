import 'package:inventory/helper/logger.dart';
import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/gobal_module/gobal_controller.dart'; // 🔥 GlobalStore for RAM Access
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/inventory/repo/inventory_repo.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../helper/helper.dart';

class InventroyController extends GetxController
    with CacheManager, LocalService {
  // Existing Variables (Nahi badle gaye - As per your instruction)

  InventoryScanRepo inventoryScanRepo = InventoryScanRepo();
  RxList<ProductModel> scannedProductDetails = <ProductModel>[].obs;
  //RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  //RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
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

  Future<(bool existProductOrNot, BarcodeExistingData barcodeExistingData)>
  existingProductInfo(String barcode) async {
    isExistingProductInfo.value = true;
    var res = await fetchProductByBarcode(barcode: barcode);
    try {
      if (res.success == false &&
          res.msg!.contains('Product not found with barcode')) {
        return (false, res.data!);
      } else {
        return (false, res.data!);
      }
    } catch (e) {
      AppLogger.info(("🚨 Info Error: $e").toString());
      showSnackBar(error: e.toString());
      return (false, BarcodeExistingData());
    } finally {
      isExistingProductInfo.value = false;
    }
  }

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

  Future<BarcodeExistingModel> fetchProductByBarcode({
    required String barcode,
  }) async {
    var res = await inventoryScanRepo.fetchProductByBarcode(barcode: barcode);
    return res;
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
