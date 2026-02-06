import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
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
      print("🔍 Scanning Barcode: $barcode");

      // Yahan maine relationship name '!' ke saath specify kar diya hai
      final response =
          await SupabaseConfig.from('product_barcodes')
              .select('''
          barcode,
          products!inner (
            id, 
            name, 
            flavour, 
            weight, 
            rack, 
            level, 
            is_loose_category,
            product_stock!product_stock_product_id_fkey (
              quantity, 
              selling_price, 
              stock_type, 
              location
            ),
            loose_stocks (
              quantity, 
              selling_price
            )
          )
        ''')
              .eq('barcode', barcode)
              .maybeSingle();

      if (response == null || response['products'] == null) {
        print("❌ No product found for this barcode");
        return (false, ProductModel());
      }

      final p = response['products'];

      // Safety check for lists
      final List stockRaw = p['product_stock'] as List? ?? [];
      final List looseRaw = p['loose_stocks'] as List? ?? [];

      // Filter Packet (Shop only)
      final packetData = stockRaw.firstWhere(
        (s) => s['location'] == 'shop' && s['stock_type'] == 'packet',
        orElse: () => null,
      );

      final looseData = looseRaw.isNotEmpty ? looseRaw[0] : null;
      bool isLoose = p['is_loose_category'] ?? false;

      double finalPrice = 0.0;
      int finalQty = 0;

      // Priority logic
      if (isLoose && looseData != null) {
        finalQty = int.tryParse(looseData['quantity']?.toString() ?? '0') ?? 0;
        finalPrice =
            double.tryParse(looseData['selling_price']?.toString() ?? '0.0') ??
            0.0;
      } else if (packetData != null) {
        finalQty = int.tryParse(packetData['quantity']?.toString() ?? '0') ?? 0;
        finalPrice =
            double.tryParse(packetData['selling_price']?.toString() ?? '0.0') ??
            0.0;
      }

      final model = ProductModel(
        id: p['id']?.toString() ?? '',
        name: p['name'] ?? 'No Name',
        barcode: barcode,
        flavor: p['flavour']?.toString() ?? '',
        weight: p['weight']?.toString() ?? '',
        rack: p['rack']?.toString() ?? '',
        level: p['level']?.toString() ?? '',
        isLoosed: isLoose,
        quantity: finalQty,
        sellingPrice: finalPrice,
      );

      stockqty.value = finalQty;
      existProductName.value = model.name ?? '';

      return (true, model);
    } catch (e) {
      print("🚨 FIXED Mapping Error: $e");
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
      dynamic response;

      // 1. Pehle barcode se product_id nikalo (Universal for both types)
      final barcodeResponse =
          await SupabaseConfig.from(
            'product_barcodes',
          ).select('product_id').eq('barcode', barcode).maybeSingle();

      if (barcodeResponse == null) {
        showMessage(message: "❌ Barcode not found");
        return;
      }

      final String productId = barcodeResponse['product_id'];

      // 2. Stock fetch karo based on sellType
      if (sellType.toLowerCase() == 'loose') {
        response =
            await SupabaseConfig.from('loose_stocks')
                .select('''
            quantity, 
            selling_price, 
            products!loose_stocks_product_id_fkey(id, name, weight, flavour)
          ''')
                .eq('product_id', productId)
                .eq('user_id', userId!)
                .maybeSingle();
      } else {
        response =
            await SupabaseConfig.from('product_stock')
                .select('''
            quantity, 
            selling_price, 
            products!product_stock_product_id_fkey(id, name, weight, flavour)
          ''')
                .eq('product_id', productId)
                .eq('stock_type', 'packet')
                .eq('location', 'shop')
                .eq('user_id', userId!)
                .maybeSingle();
      }

      if (response == null || response['products'] == null) {
        showMessage(message: "❌ Stock not found for $sellType");
        return;
      }

      final productData = response['products'];
      final String currentProductId = productData['id']; // Asli Product ID
      final int availableQty = response['quantity'] ?? 0;
      final double price = (response['selling_price'] ?? 0.0).toDouble();

      if (availableQty <= 0) {
        qtyIsNotEnough();
        return;
      }

      // 3. Local Cart Management (FIXED LOGIC)
      final List<ProductModel> cartList = await retrieveCartProductList();

      // Yahan hum 'id' (Product UUID) se check kar rahe hain, barcode se nahi
      final index = cartList.indexWhere(
        (p) => p.id == currentProductId && p.sellType == sellType,
      );

      if (index != -1) {
        // Agar wahi product mil gaya, toh quantity check karo
        if ((cartList[index].quantity ?? 0) >= availableQty) {
          qtyIsNotEnough();
          return;
        }
        // Quantity badhao
        cartList[index].quantity = (cartList[index].quantity ?? 0) + 1;
        print("✅ Quantity Updated for: ${productData['name']}");
      } else {
        // Agar bilkul naya product hai, toh hi add karo
        cartList.add(
          ProductModel(
            barcode: barcode,
            id: currentProductId,
            name: productData['name'],
            sellingPrice: price,
            quantity: 1,
            sellType: sellType,
            isLoosed: sellType.toLowerCase() == 'loose',
            flavor: productData['flavour'],
            weight: productData['weight'],
          ),
        );
        print("🆕 New Product Added to Cart: ${productData['name']}");
      }

      // 4. Save and Update UI
      saveCartProductList(cartList);
      scannedProductDetails.assignAll(cartList);
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
}
