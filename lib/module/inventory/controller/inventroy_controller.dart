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
  // Existing Variables
  RxList<ProductModel> scannedProductDetails = <ProductModel>[].obs;
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
  RxList<ProductModel> looseCatogorieList = <ProductModel>[].obs;
  RxList<ProductModel> looseInventoryLis = <ProductModel>[].obs;
  RxList<ProductModel> fullLooseSellingList = <ProductModel>[].obs;

  final userId = SupabaseConfig.auth.currentUser?.id;

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

      if (res == null || res['products'] == null)
        return (false, ProductModel());

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
    required String sellType, // 'Packet' or 'Loose'
    required VoidCallback afterProductAdding,
    required VoidCallback qtyIsNotEnough,
  }) async {
    if (userId == null) return;

    try {
      // 1. Barcode se sirf Product ID lo (Simple call)
      final bRes =
          await SupabaseConfig.from(
            'product_barcodes',
          ).select('product_id').eq('barcode', barcode).maybeSingle();

      if (bRes == null) {
        showMessage(message: "❌ Barcode Not Found");
        return;
      }

      final String pId = bRes['product_id'];

      // 2. Product ki info lo (Bina stock join ke)
      final pRes =
          await SupabaseConfig.from(
            'products',
          ).select('id, name, weight, flavour').eq('id', pId).maybeSingle();

      if (pRes == null) {
        showMessage(message: "❌ Product Info Not Found");
        return;
      }

      // 3. Stock direct table se fetch karo (No Joins!)
      dynamic stockData;
      if (sellType.toLowerCase() == 'loose') {
        stockData =
            await SupabaseConfig.from('loose_stocks')
                .select('quantity, selling_price')
                .eq('product_id', pId)
                .eq('user_id', userId!) // User ID check
                .maybeSingle();
      } else {
        stockData =
            await SupabaseConfig.from('product_stock')
                .select('quantity, selling_price')
                .eq('product_id', pId)
                .eq('stock_type', 'packet')
                .eq('location', 'shop') // Sirf Shop ka stock
                .eq('user_id', userId!)
                .maybeSingle();
      }

      // DEBUGGING: Console mein check karo kya aa raha hai
      print("Bhai, Stock Data mila: $stockData");

      if (stockData == null) {
        qtyIsNotEnough(); // Agar row hi nahi mili
        return;
      }

      // String/Null ko safely handle karne ke liye tryParse
      final int availableQty =
          int.tryParse(stockData['quantity']?.toString() ?? '0') ?? 0;
      final double price =
          double.tryParse(stockData['selling_price']?.toString() ?? '0.0') ??
          0.0;

      if (availableQty <= 0) {
        qtyIsNotEnough(); // Stock 0 hai
        return;
      }

      // 4. Cart logic (Same as before)
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
      } else {
        cartList.add(
          ProductModel(
            barcode: barcode,
            id: pId,
            name: pRes['name'],
            sellingPrice: price,
            quantity: 1,
            sellType: sellType,
            isLoosed: sellType.toLowerCase() == 'loose',
            flavor: pRes['flavour'],
            weight: pRes['weight'],
          ),
        );
      }

      saveCartProductList(cartList);
      scannedProductDetails.assignAll(cartList);
      afterProductAdding();
    } catch (e) {
      print("🚨 Final Scan Error: $e");
      showMessage(message: "Error processing scan: $e");
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
