import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/gobal_controller.dart'; // 🔥 GlobalStore for RAM Access
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../helper/helper.dart';

class InventroyController extends GetxController
    with CacheManager, LocalService {
  final userId = SupabaseConfig.auth.currentUser?.id;

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
  Future<(bool existProductOrNot, ProductModel productModels)>
  existingProductInfo(String barcode) async {
    if (userId == null) return (false, ProductModel());
    isExistingProductInfo.value = true;

    try {
      // 1. RAM Sync Check (GlobalStore) - Based on Instruction [2026-01-31]
      // Multiple barcodes ke liye humara map best hai.
      final globalStore = Get.find<GlobalStore>();
      var ramProductData = globalStore.barcodeToProductMap[barcode];

      if (ramProductData != null) {
        final model = ProductModel.fromJson(ramProductData.toJson());
        existProductName.value = model.name ?? '';
        isExistingProductInfo.value = false;
        return (true, model);
      }

      // 2. Fallback to Hive (LocalService)
      final localProduct = LocalService.searchByBarcode(barcode);
      if (localProduct != null) {
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
        existProductName.value = model.name ?? '';
        return (true, model);
      }

      return (false, ProductModel());
    } catch (e) {
      print("🚨 Info Error: $e");
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
          showMessage(message: "❌ Product Not Found");
          return;
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
      print("🚨 Scan Error: $e");
      showMessage(message: "Error processing scan");
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
