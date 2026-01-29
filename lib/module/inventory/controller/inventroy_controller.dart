import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../helper/helper.dart';

class InventroyController extends GetxController with CacheManager {
  // 🔥 FIREBASE REMOVED
  // final FirebaseAuth auth = FirebaseAuth.instance;

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
  void onInit() async {
    flag = data['flag'];
    navigate = data['navigate'];

    mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: [BarcodeFormat.all],
    );
    player = AudioPlayer();
    super.onInit();
  }

  // ================================
  // 🔥 FETCH LOOSE INVENTORY (SUPABASE)
  // ================================
  Future<List<ProductModel>> fetchLooseInventory() async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await SupabaseConfig.from('product_stock')
          .select('''
            quantity,
            selling_price,
            stock_type,
            products (
              id,
              name,
              category,
              animal_type,
              is_flavor_and_weight_not_required
            )
          ''')
          .eq('user_id', userId)
          .eq('location', 'shop')
          .eq('stock_type', 'loose')
          .eq('is_active', true);

      looseInventoryLis.value =
          (response as List).map((e) {
            final product = Map<String, dynamic>.from(e['products']);
            product['quantity'] = e['quantity'];
            product['selling_price'] = e['selling_price'];
            product['is_loose'] = true;
            looseOldQty = e['quantity'];
            return ProductModel.fromJson(product);
          }).toList();

      return looseInventoryLis;
    } catch (e) {
      showMessage(message: e.toString());
      return [];
    }
  }

  void cameraStart() {
    mobileScannerController.start();
    Get.back();
  }

  // ================================
  // 🔥 EXISTING PRODUCT CHECK
  // ================================
  Future<(bool existProductOrNot, ProductModel productModels)>
  existingProductInfo(String barcode) async {
    isExistingProductInfo.value = true;

    try {
      final response = await SupabaseConfig.from('product_stock')
          .select('''
            quantity,
            location,
            stock_type,
            selling_price,
            products (
              id,
              name,
              category
            )
          ''')
          .eq('user_id', userId ?? '')
          .eq('location', 'shop')
          .eq('products.barcodes.barcode', barcode)
          .limit(1);

      if ((response as List).isNotEmpty) {
        final e = response.first;
        final product = Map<String, dynamic>.from(e['products']);
        product['quantity'] = e['quantity'];
        product['selling_price'] = e['selling_price'];
        product['is_loose'] = e['stock_type'] == 'loose';

        final model = ProductModel.fromJson(product);
        stockqty.value = model.quantity?.toInt() ?? 0;
        existProductName.value = model.name ?? '';
        return (true, model);
      }
      return (false, ProductModel());
    } finally {
      isExistingProductInfo.value = false;
    }
  }

  // ================================
  // 🔥 CHECK IF LOOSE PRODUCT EXISTS
  // ================================
  Future<bool> fetchLooseProductByBarcode({required String barcode}) async {
    isProductSaving.value = true;

    if (userId == null) return false;

    final response = await SupabaseConfig.from('product_stock')
        .select('stock_type, products (name)')
        .eq('user_id', userId ?? '')
        .eq('location', 'shop')
        .eq('stock_type', 'loose')
        .eq('products.barcodes.barcode', barcode)
        .limit(1);

    if ((response as List).isNotEmpty) {
      existProductName.value = response.first['products']['name'];
      return true;
    }
    return false;
  }

  // ================================
  // 🔥 HANDLE SCAN (CORE SELL LOGIC)
  // ================================
  Future<void> handleScan({
    required String barcode,
    required String sellType, // packet | loose
    required VoidCallback afterProductAdding,
    required VoidCallback qtyIsNotEnough,
  }) async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;

    final stockType = sellType.toLowerCase() == 'loose' ? 'loose' : 'packet';

    final response = await SupabaseConfig.from('product_stock')
        .select('''
          quantity,
          selling_price,
          stock_type,
          products (
            id,
            name,
            category,
            animal_type,
            weight,
            flavour,
            color,
            rack,
            level,
            is_flavor_and_weight_not_required
          )
        ''')
        .eq('user_id', userId)
        .eq('location', 'shop')
        .eq('stock_type', stockType)
        .eq('products.barcodes.barcode', barcode)
        .limit(1);

    if ((response as List).isEmpty) {
      showMessage(message: "❌ Product not available in SHOP");
      return;
    }

    final e = response.first;
    final productMap = Map<String, dynamic>.from(e['products']);
    productMap['quantity'] = e['quantity'];
    productMap['selling_price'] = e['selling_price'];
    productMap['is_loose'] = stockType == 'loose';
    productMap['sell_type'] = sellType;

    final product = ProductModel.fromJson(productMap);

    if ((product.quantity ?? 0) <= 0) {
      qtyIsNotEnough();
      return;
    }

    final cartList = await retrieveCartProductList();

    final index = cartList.indexWhere(
      (p) => p.barcode == barcode && p.sellType == sellType,
    );

    if (index != -1) {
      final cartQty = cartList[index].quantity ?? 0;
      final maxQty = product.quantity ?? 0;

      if (cartQty >= maxQty) {
        qtyIsNotEnough();
        return;
      }
      cartList[index].quantity = cartQty + 1;
    } else {
      cartList.add(
        ProductModel(
          barcode: barcode,
          name: product.name,
          sellingPrice: product.sellingPrice,
          purchasePrice: product.purchasePrice,
          quantity: 1,
          sellType: sellType,
          isActive: true,
          isLoosed: stockType == 'loose',
          category: product.category,
          animalType: product.animalType,
          weight: product.weight,
          flavor: product.flavor,
          color: product.color,
          location: 'shop',
          rack: product.rack,
          level: product.level,
          id: product.id,
          isFlavorAndWeightNotRequired: product.isFlavorAndWeightNotRequired,
        ),
      );
    }

    saveCartProductList(cartList);

    scannedProductDetails
      ..clear()
      ..addAll(cartList);

    afterProductAdding();
  }

  Future<void> stopCameraAfterDetect(BarcodeCapture barcodes) async {
    barcodeValue.value = barcodes.barcodes.first.rawValue.toString();
    mobileScannerController.stop();
  }
}



// class InventroyController extends GetxController with CacheManager {
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   RxList<ProductModel> scannedProductDetails = <ProductModel>[].obs;
//   RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
//   RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
//   RxList<ProductModel> looseCatogorieList = <ProductModel>[].obs;
//   RxList<ProductModel> looseInventoryLis = <ProductModel>[].obs;
//   RxList<ProductModel> fullLooseSellingList = <ProductModel>[].obs;
//   RxBool isTreatSelected = false.obs;
//   RxBool isCameraStop = false.obs;
//   RxBool isProductSaving = false.obs;
//   RxBool isScannedQtyOutOfStock = false.obs;
//   RxBool isExistingProductInfo = false.obs;
//   RxBool isDoneButtonReq = false.obs;
//   RxBool isfullLooseSellingListLoading = false.obs;
//   late MobileScannerController mobileScannerController;
//   double totalAmount = 0.0;
//   RxInt scannedQty = 0.obs;
//   RxString barcodeValue = ''.obs;
//   String? selectedManuallySell;
//   int looseOldQty = 0;
//   RxString existProductName = ''.obs;
//   RxInt stockqty = 0.obs;
//   bool isLoose = false;
//   var data = Get.arguments;
//   bool? flag;
//   String? navigate;
//   AudioPlayer? player;

//   @override
//   void onInit() async {
//     flag = data['flag'];
//     navigate = data['navigate'];
//     mobileScannerController = MobileScannerController(
//       detectionSpeed: DetectionSpeed.noDuplicates,
//       formats: [BarcodeFormat.all],
//     );
//     player = AudioPlayer();
//     super.onInit();
//   }

//   Future<List<ProductModel>> fetchLooseInventory() async {
//     final uid = auth.currentUser?.uid;

//     try {
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(uid)
//               .collection('looseProducts')
//               .where('isActive', isEqualTo: true)
//               .get();

//       looseInventoryLis.value =
//           snapshot.docs.map((doc) {
//             final data = doc.data();
//             data['id'] = doc.id;
//             looseOldQty = data['quantity'];

//             return ProductModel.fromJson(data);
//           }).toList();

//       return looseInventoryLis;
//     } on FirebaseAuthException catch (e) {
//       showMessage(message: e.toString());
//       return [];
//     }
//   }

//   void cameraStart() {
//     mobileScannerController.start();
//     Get.back();
//   }

//   Future<(bool existProductOrNot, ProductModel productModels)>
//   existingProductInfo(String uid, String barcode) async {
//     isExistingProductInfo.value = true;
//     try {
//       final productRef = FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .collection('products')
//           .doc(barcode);
//       final existingDoc = await productRef.get();
//       final product = ProductModel.fromJson(existingDoc.data() ?? {});
//       if (existingDoc.exists && product.isActive == true) {
//         stockqty.value = product.quantity?.toInt() ?? 0;
//         existProductName.value = product.name ?? '';
//         //loooseProductName.text = product.name ?? '';
//         return (true, product);
//       }
//       return (false, product);
//     } finally {
//       isExistingProductInfo.value = false;
//     }
//   }

//   Future<bool> fetchLooseProductByBarcode({required String barcode}) async {
//     isProductSaving.value = true;
//     final uid = auth.currentUser?.uid;
//     if (uid == null) return false;
//     final productRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .collection('products')
//         .doc(barcode);
//     final doc = await productRef.get();
//     if (doc.exists) {
//       final data = doc.data();
//       final isLoose = data?['isLoose'] ?? false;
//       existProductName.value = data?['name'] ?? false;
//       // loooseProductName.text = data?['name'] ?? false;
//       if (isLoose) {
//         return true;
//       }
//       return false;
//     } else {
//       return false;
//     }
//   }

//   Future<void> handleScan({
//     required String barcode,
//     required String sellType, // packet | loose
//     required VoidCallback afterProductAdding,
//     required VoidCallback qtyIsNotEnough,
//   }) async {
//     final uid = auth.currentUser?.uid;
//     if (uid == null) return;

//     final firestore = FirebaseFirestore.instance;
//     ProductModel? product;

//     // ===============================
//     // 1️⃣ FETCH PRODUCT
//     // ===============================
//     if (sellType.toLowerCase() == 'loose') {
//       final snap =
//           await firestore
//               .collection('users')
//               .doc(uid)
//               .collection('looseProducts')
//               .doc(barcode)
//               .get();

//       if (!snap.exists) {
//         showMessage(
//           message: "❌ Loose product not available, please add loose stock",
//         );
//         return;
//       }
//       product = ProductModel.fromJson(snap.data()!);
//     } else {
//       final query =
//           await firestore
//               .collection('users')
//               .doc(uid)
//               .collection('products')
//               .where('barcode', isEqualTo: barcode)
//               .where('isActive', isEqualTo: true)
//               .limit(1)
//               .get();

//       if (query.docs.isEmpty) {
//         showMessage(message: "❌ Product not found in SHOP");
//         return;
//       }
//       product = ProductModel.fromJson(query.docs.first.data());
//     }

//     // ===============================
//     // 2️⃣ STOCK CHECK
//     // ===============================
//     if ((product.quantity ?? 0) <= 0) {
//       qtyIsNotEnough();
//       return;
//     }

//     // ===============================
//     // 3️⃣ LOAD CART (ONLY ONE SOURCE)
//     // ===============================
//     final cartList = await retrieveCartProductList();

//     final index = cartList.indexWhere(
//       (p) => p.barcode == barcode && p.sellType == sellType,
//     );

//     if (index != -1) {
//       print('CART QTY: ${cartList[index].quantity}');
//       print('PRODUCT QTY: ${product.quantity}');

//       final cartQty = cartList[index].quantity ?? 0;
//       final maxQty = product.quantity ?? 0;

//       final canAddMore = cartQty < maxQty;

//       if (!canAddMore) {
//         qtyIsNotEnough();
//         return;
//       }
//       cartList[index].quantity = cartQty + 1;
//     } else {
//       // add new item
//       cartList.add(
//         ProductModel(
//           barcode: product.barcode,
//           name: product.name,
//           sellingPrice: product.sellingPrice,
//           purchasePrice: product.purchasePrice,
//           quantity: 1,
//           sellType: sellType,
//           isActive: product.isActive,
//           isLoosed: product.isLoosed,

//           category: product.category,
//           animalType: product.animalType,
//           weight: product.weight,
//           flavor: product.flavor,
//           color: product.color,

//           location: product.location,
//           rack: product.rack,
//           level: product.level,
//           createdDate: product.createdDate,
//           createdTime: product.createdTime,
//           expireDate: product.expireDate,
//           discount: product.discount,
//           billNo: product.billNo,
//           id: product.id,
//           isFlavorAndWeightNotRequired: product.isFlavorAndWeightNotRequired,
//         ),
//       );
//     }

//     // ===============================
//     // 4️⃣ SAVE & SYNC UI
//     // ===============================
//     saveCartProductList(cartList);

//     scannedProductDetails
//       ..clear()
//       ..addAll(cartList);

//     afterProductAdding();
//   }

//   Future<void> stopCameraAfterDetect(BarcodeCapture barcodes) async {
//     barcodeValue.value = barcodes.barcodes.first.rawValue.toString();
//     //barcode.text = barcodeValue.value;
//     mobileScannerController.stop();
//   }
// }




  // Future<void> fetchfullLooseSellingList() async {
  //   isfullLooseSellingListLoading.value = true;
  //   //var fetchLooseCategorys = await fetchLooseCategory();
  //   // var fetchLooseInventorys = await fetchLooseInventory();
  //   // fullLooseSellingList.addAll(fetchLooseCategorys);
  //   //  fullLooseSellingList.addAll(fetchLooseInventorys);
  //   isfullLooseSellingListLoading.value = false;
  //   for (var lis in fullLooseSellingList) {
  //     customMessageOrErrorPrint(message: 'fullLooseSellingList is ${lis.name}');
  //     customMessageOrErrorPrint(
  //       message: 'fullLooseSellingList is ${lis.sellingPrice}',
  //     );
  //   }
  // }

// Future<void> fetchProductByBarcode({
  //   required String barcode,
  //   required Function()? elseFun,
  //   required Function() qtyIsNotEnough,
  //   required Function() afterProductAdding,
  // }) async {
  //   isProductSaving.value = true;
  //   final uid = auth.currentUser?.uid;
  //   if (uid == null) return;
  //   final productRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .collection('products')
  //       .doc(barcode);
  //   final doc = await productRef.get();

  //   if (doc.exists) {
  //     final product = ProductModel.fromJson(doc.data()!);
  //     // handleScan(
  //     //   product: product,
  //     //   afterProductAdding: afterProductAdding,
  //     //   qtyIsNotEnough: qtyIsNotEnough,
  //     // );
  //   } else {
  //     elseFun!();
  //   }
  // }


  // Future<List<ProductModel>> fetchLooseCategory() async {
  //   final uid = auth.currentUser?.uid;

  //   try {
  //     final snapshot =
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(uid)
  //             .collection('looseSellCategory')
  //             .get();

  //     looseCatogorieList.value =
  //         snapshot.docs.map((doc) {
  //           final data = doc.data();
  //           data['id'] = doc.id;
  //           return ProductModel.fromJson(data);
  //         }).toList();
  //     return looseCatogorieList;
  //   } on FirebaseAuthException catch (e) {
  //     showMessage(message: e.toString());
  //     return [];
  //   }
  // }