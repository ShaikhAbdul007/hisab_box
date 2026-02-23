import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Mixin
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../helper/helper.dart';

class InventroyController extends GetxController
    with CacheManager, LocalService {
  final userId = SupabaseConfig.auth.currentUser?.id;

  // Existing Variables (Nahi badle gaye)
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
  // 🔥 EXISTING PRODUCT CHECK (HIVE FIRST)
  // ==========================================
  Future<(bool existProductOrNot, ProductModel productModels)>
  existingProductInfo(String barcode) async {
    if (userId == null) return (false, ProductModel());
    isExistingProductInfo.value = true;

    try {
      // 1. Sabse pehle Hive (LocalService) mein dhoondo (Offline First)
      final localProduct = LocalService.searchByBarcode(barcode);

      if (localProduct != null) {
        existProductName.value = localProduct.name ?? '';
        isExistingProductInfo.value = false;
        print("📦 Found in Local Cache: ${localProduct.name}");
        return (true, localProduct);
      } else {
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
          isLoosed: p['is_loose_category'] ?? false,
          flavor: p['flavour'],
          weight: p['weight'],
          animalType: p['animalType'],
          location: p['location'],
          isActive: p['isActive'],
        );

        existProductName.value = model.name ?? '';
        return (true, model);
      }

      // 2. Agar Hive mein nahi hai, tabhi Supabase jao (Net Check)
    } catch (e) {
      print("🚨 Info Error: $e");
      return (false, ProductModel());
    } finally {
      isExistingProductInfo.value = false;
    }
  }

  // ==========================================
  // 🔥 HANDLE SCAN (OFFLINE-READY)
  // ==========================================
  Future<void> handleScan({
    required String barcode,
    required String sellType,
    required VoidCallback afterProductAdding,
    required VoidCallback qtyIsNotEnough,
  }) async {
    if (userId == null) return;

    try {
      // 🎯 STEP 1: Search in Hive (Offline First)
      ProductModel? product = LocalService.searchByBarcode(barcode);

      // 🎯 STEP 2: If not in Hive, Fetch from Supabase with Nested Join
      if (product == null) {
        print("☁️ Hive mein nahi mila, Supabase se fetch kar raha hoon...");

        final res =
            await SupabaseConfig.from('product_barcodes')
                .select('''
          product_id,
          barcode,
          products!inner (
            *,
            product_stock!inner (*)
          )
        ''')
                .eq('barcode', barcode)
                .maybeSingle();

        if (res != null) {
          // Nested data nikalna (products -> product_stock)
          final Map<String, dynamic> pData = res['products'];
          final List<dynamic> sDataList = pData['product_stock'] ?? [];

          // Model banana
          product = ProductModel.fromJson(pData);

          // Stock data manually map karna (kyunki products ke andar nested list hai)
          if (sDataList.isNotEmpty) {
            product.quantity =
                double.tryParse(sDataList[0]['quantity'].toString()) ?? 0;
            product.sellingPrice =
                double.tryParse(sDataList[0]['selling_price'].toString()) ?? 0;
          }

          product.barcode = barcode; // Scanned barcode set karna
          print("✅ Found in Supabase: ${product.name}");
        } else {
          showMessage(message: "❌ Product Not Found in Database");
          return;
        }
      }

      // 🎯 STEP 3: Stock Check
      // Local data mein quantity update ho sakti hai stream se, isliye hamesha latest lein
      double availableQty =
          double.tryParse(product.quantity?.toString() ?? '0') ?? 0;

      if (availableQty <= 0) {
        qtyIsNotEnough(); // UI par "Out of Stock" dikhayega
        return;
      }

      // 🎯 STEP 4: Cart Logic
      final List<ProductModel> cartList = await retrieveCartProductList();

      // Product ID se check karo cart mein (pId ki jagah product.id)
      final index = cartList.indexWhere(
        (p) => p.id == product?.id && p.sellType == sellType,
      );

      if (index != -1) {
        // Agar cart mein quantity stock se zyada ho rahi hai
        if ((cartList[index].quantity ?? 0) >= availableQty) {
          qtyIsNotEnough();
          return;
        }
        cartList[index].quantity = (cartList[index].quantity ?? 0) + 1;
        cartList[index].barcode =
            barcode; // Barcode update in case multiple barcodes used
      } else {
        // Naya item cart mein add karna
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
          ),
        );
      }

      // 🎯 STEP 5: Save and UI Update
      saveCartProductList(cartList);
      scannedProductDetails.assignAll(cartList);
      scannedProductDetails.refresh();

      // Feedback
      player?.play(AssetSource('sounds/beep.mp3'));
      afterProductAdding();
    } catch (e) {
      print("🚨 Final Scan Error: $e");
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
