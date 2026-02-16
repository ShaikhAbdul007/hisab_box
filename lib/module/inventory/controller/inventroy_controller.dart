import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../helper/helper.dart';

class InventroyController extends GetxController with CacheManager {
  final userId = SupabaseConfig.auth.currentUser?.id;
  // Existing Variables
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
  // 🔥 EXISTING PRODUCT CHECK (MULTI-TABLE JOIN)
  // ==========================================
  Future<(bool existProductOrNot, ProductModel productModels)>
  existingProductInfo(String barcode) async {
    if (userId == null) return (false, ProductModel());
    isExistingProductInfo.value = true;

    try {
      // Sirf category aur basic details fetch karo
      final res =
          await SupabaseConfig.from('product_barcodes')
              .select(
                'product_id, products!fk_product_barcodes_products(id, name, flavour, weight, is_loose_category)',
              )
              .eq('barcode', barcode)
              .maybeSingle();

      if (res == null || res['products'] == null) {
        return (false, ProductModel());
      }

      final p = res['products'];

      final model = ProductModel(
        id: p['id'],
        name: p['name'],
        barcode: barcode,
        isLoosed:
            p['is_loose_category'] ??
            false, // Ye batayega ki Pop-up dikhana hai ya nahi
        flavor: p['flavour'],
        weight: p['weight'],
      );

      existProductName.value = model.name ?? '';
      return (true, model);
    } catch (e) {
      print("🚨 Info Error: $e");
      return (false, ProductModel());
    } finally {
      isExistingProductInfo.value = false;
    }
  }

  // ==========================================
  // 🔥 HANDLE SCAN (SELL PACKET OR LOOSE)
  // ==========================================

  Future<void> handleScan({
    required String barcode,
    required String sellType,
    required VoidCallback afterProductAdding,
    required VoidCallback qtyIsNotEnough,
  }) async {
    if (userId == null) return;

    // 🎯 STEP 0: Pehle hi check karlo ki scan se value aa bhi rahi hai ya nahi
    print("🔍 Scan Triggered: Barcode=$barcode, Type=$sellType");
    if (barcode.isEmpty || barcode == "null") {
      showMessage(message: "❌ Invalid Barcode Scanned");
      return;
    }

    try {
      // 1. Barcode se ID lo
      final bRes =
          await SupabaseConfig.from(
            'product_barcodes',
          ).select('product_id').eq('barcode', barcode).maybeSingle();

      if (bRes == null) {
        showMessage(message: "❌ Barcode Not Found");
        return;
      }

      final String pId = bRes['product_id'];

      // 2. Product Info
      final pRes =
          await SupabaseConfig.from(
            'products',
          ).select('id, name, weight, flavour').eq('id', pId).maybeSingle();

      if (pRes == null) return;

      // 3. Stock Check (Double safe)
      dynamic stockData;
      if (sellType.toLowerCase() == 'loose') {
        stockData =
            await SupabaseConfig.from(
              'loose_stocks',
            ).select().eq('product_id', pId).maybeSingle();
      } else {
        stockData =
            await SupabaseConfig.from('product_stock')
                .select()
                .eq('product_id', pId)
                .eq('stock_type', 'packet')
                .maybeSingle();
      }

      if (stockData == null) {
        qtyIsNotEnough();
        return;
      }

      final double availableQty =
          double.tryParse(stockData['quantity']?.toString() ?? '0') ?? 0;
      final double price =
          double.tryParse(stockData['selling_price']?.toString() ?? '0') ?? 0;

      if (availableQty <= 0) {
        qtyIsNotEnough();
        return;
      }

      // 4. Cart Logic (Proper Mapping)
      final List<ProductModel> cartList = await retrieveCartProductList();
      final index = cartList.indexWhere(
        (p) => p.id == pId && p.sellType == sellType,
      );

      if (index != -1) {
        if ((cartList[index].quantity ?? 0) >= availableQty) {
          qtyIsNotEnough();
          return;
        }
        cartList[index].quantity = (cartList[index].quantity ?? 0) + 1;
        cartList[index].barcode = barcode; // 🎯 Re-assign barcode
      } else {
        // 🎯 FORCE ASSIGN: Variable ko direct use karo
        final newItem = ProductModel(
          barcode: barcode, // Ye line pakka honi chahiye
          id: pId,
          name: pRes['name'],
          sellingPrice: price,
          quantity: 1.0,
          sellType: sellType,
          isLoosed: sellType.toLowerCase() == 'loose',
          flavor: pRes['flavour'],
          weight: pRes['weight'],
        );
        cartList.add(newItem);
      }

      // 5. Save and Refresh
      saveCartProductList(cartList);

      // Sabse zaroori: GetX list ko manually update karo
      scannedProductDetails.assignAll(cartList);
      scannedProductDetails.refresh();

      afterProductAdding();
      print("✅ Cart Updated. Total items: ${scannedProductDetails.length}");
    } catch (e) {
      print("🚨 Final Scan Error: $e");
    }
  }

  void cameraStart() {
    mobileScannerController.start();
  }

  Future<void> stopCameraAfterDetect(BarcodeCapture barcodes) async {
    barcodeValue.value = barcodes.barcodes.first.rawValue.toString();
    mobileScannerController.stop();
  }
}
