import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../helper/helper.dart';

class InventroyController extends GetxController with CacheManager {
  final FirebaseAuth auth = FirebaseAuth.instance;
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
      formats: [
        // BarcodeFormat.code128,
        // BarcodeFormat.code39,
        // BarcodeFormat.code93,
        // BarcodeFormat.codabar,
        // BarcodeFormat.ean13,
        // BarcodeFormat.ean8,
        // BarcodeFormat.aztec,
        // BarcodeFormat.dataMatrix,
        // BarcodeFormat.itf,
        // BarcodeFormat.upcE,
        // BarcodeFormat.pdf417,
        BarcodeFormat.all,
      ],
    );
    player = AudioPlayer();

    await fetchfullLooseSellingList();
    super.onInit();
  }

  Future<void> fetchfullLooseSellingList() async {
    isfullLooseSellingListLoading.value = true;
    var fetchLooseCategorys = await fetchLooseCategory();
    var fetchLooseInventorys = await fetchLooseInventory();
    fullLooseSellingList.addAll(fetchLooseCategorys);
    fullLooseSellingList.addAll(fetchLooseInventorys);
    isfullLooseSellingListLoading.value = false;
    for (var lis in fullLooseSellingList) {
      customMessageOrErrorPrint(message: 'fullLooseSellingList is ${lis.name}');
      customMessageOrErrorPrint(
        message: 'fullLooseSellingList is ${lis.sellingPrice}',
      );
    }
  }

  Future<List<ProductModel>> fetchLooseCategory() async {
    final uid = auth.currentUser?.uid;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('looseSellCategory')
              .get();

      looseCatogorieList.value =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ProductModel.fromJson(data);
          }).toList();
      return looseCatogorieList;
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
      return [];
    }
  }

  Future<List<ProductModel>> fetchLooseInventory() async {
    final uid = auth.currentUser?.uid;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('looseProducts')
              .get();

      looseInventoryLis.value =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            looseOldQty = data['quantity'];

            return ProductModel.fromJson(data);
          }).toList();

      return looseInventoryLis;
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
      return [];
    }
  }

  void cameraStart() {
    mobileScannerController.start();
    Get.back();
  }

  Future<(bool existProductOrNot, ProductModel productModels)>
  existingProductInfo(String uid, String barcode) async {
    final productRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('products')
        .doc(barcode);
    final existingDoc = await productRef.get();
    final product = ProductModel.fromJson(existingDoc.data() ?? {});
    if (existingDoc.exists) {
      stockqty.value = product.quantity ?? 0;
      existProductName.value = product.name ?? '';
      //loooseProductName.text = product.name ?? '';
      return (true, product);
    }
    return (false, product);
  }

  Future<void> fetchProductByBarcode({
    required String barcode,
    required Function()? elseFun,
    required Function() qtyIsNotEnough,
    required Function() afterProductAdding,
  }) async {
    isProductSaving.value = true;
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    final productRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('products')
        .doc(barcode);
    final doc = await productRef.get();

    if (doc.exists) {
      final product = ProductModel.fromJson(doc.data()!);
      handleScan(
        product: product,
        afterProductAdding: afterProductAdding,
        qtyIsNotEnough: qtyIsNotEnough,
      );
    } else {
      elseFun!();
    }
  }

  Future<bool> fetchLooseProductByBarcode({required String barcode}) async {
    isProductSaving.value = true;
    final uid = auth.currentUser?.uid;
    if (uid == null) return false;
    final productRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('products')
        .doc(barcode);
    final doc = await productRef.get();
    if (doc.exists) {
      final data = doc.data();
      final isLoose = data?['isLoose'] ?? false;
      existProductName.value = data?['name'] ?? false;
      // loooseProductName.text = data?['name'] ?? false;
      if (isLoose) {
        return true;
      }
      return false;
    } else {
      return false;
    }
  }

  // void handleScan({
  //   required ProductModel product,
  //   required Function() afterProductAdding,
  //   required Function() qtyIsNotEnough,
  // }) {
  //   if (product.barcode == null || product.barcode!.isEmpty) return;
  //   final index = scannedProductDetails.indexWhere(
  //     (p) => p.barcode == product.barcode,
  //   );
  //   if (index != -1) {
  //     // Product already scanned → qty badhane ka logic
  //     if (scannedProductDetails[index].quantity! < (product.quantity ?? 0)) {
  //       scannedProductDetails[index].quantity =
  //           (scannedProductDetails[index].quantity ?? 0) + 1;
  //       scannedQty.value = scannedProductDetails[index].quantity!;
  //       afterProductAdding();
  //     } else {
  //       // Database ki quantity se zyada scan nahi kar sakte
  //       qtyIsNotEnough();
  //     }
  //   } else {
  //     // naya product hai → list me add karo with qty = 1
  //     if ((product.quantity ?? 0) > 0) {
  //       ProductModel scanned = ProductModel(
  //         barcode: product.barcode,
  //         name: product.name,
  //         sellingPrice: product.sellingPrice,
  //         quantity: 1,
  //       );
  //       scannedProductDetails.add(scanned);
  //       saveProductList(scannedProductDetails);
  //       afterProductAdding();
  //     } else {
  //       // Agar database me stock hi khatam hai
  //       qtyIsNotEnough();
  //     }
  //   }
  // }

  void handleScan({
    required ProductModel product,
    required Function() afterProductAdding,
    required Function() qtyIsNotEnough,
  }) async {
    // 🔹 Retrieve cache list
    var cacheList = await retrieveCartProductList();

    // 🔹 If cache has data, use cache logic
    if (cacheList.isNotEmpty) {
      final index = cacheList.indexWhere((p) => p.barcode == product.barcode);

      if (index != -1) {
        // Already in cache → increase qty
        if (cacheList[index].quantity! < (product.quantity ?? 0)) {
          cacheList[index].quantity = (cacheList[index].quantity ?? 0) + 1;
          saveCartProductList(cacheList);
          afterProductAdding();
        } else {
          qtyIsNotEnough();
        }
      } else {
        if ((product.quantity ?? 0) > 0) {
          ProductModel scanned = ProductModel(
            barcode: product.barcode,
            name: product.name,
            sellingPrice: product.sellingPrice,
            quantity: 1,
            animalType: product.animalType,
            billNo: product.billNo,
            box: product.box,
            category: product.category,
            color: product.color,
            createdDate: product.createdDate,
            createdTime: product.createdTime,
            discount: product.discount,
            expireDate: product.expireDate,
            flavor: product.flavor,
            isFlavorAndWeightNotRequired: product.isFlavorAndWeightNotRequired,
            id: product.id,
            isLooseCategory: product.isLooseCategory,
            isLoosed: product.isLoosed,
            location: product.location,
            purchasePrice: product.purchasePrice,
          );

          cacheList.add(scanned);
          saveCartProductList(cacheList);
          afterProductAdding();
        } else {
          qtyIsNotEnough();
        }
      }
    } else {
      if (product.barcode == null || product.barcode!.isEmpty) return;

      final index = scannedProductDetails.indexWhere(
        (p) => p.barcode == product.barcode,
      );

      if (index != -1) {
        if (scannedProductDetails[index].quantity! < (product.quantity ?? 0)) {
          scannedProductDetails[index].quantity =
              (scannedProductDetails[index].quantity ?? 0) + 1;

          scannedQty.value = scannedProductDetails[index].quantity!;
          saveCartProductList(scannedProductDetails);
          afterProductAdding();
        } else {
          qtyIsNotEnough();
        }
      } else {
        if ((product.quantity ?? 0) > 0) {
          ProductModel scanned = ProductModel(
            barcode: product.barcode,
            name: product.name,
            sellingPrice: product.sellingPrice,
            quantity: 1,
            animalType: product.animalType,
            billNo: product.billNo,
            box: product.box,
            category: product.category,
            color: product.color,
            createdDate: product.createdDate,
            createdTime: product.createdTime,
            discount: product.discount,
            expireDate: product.expireDate,
            flavor: product.flavor,
            isFlavorAndWeightNotRequired: product.isFlavorAndWeightNotRequired,
            id: product.id,
            isLooseCategory: product.isLooseCategory,
            isLoosed: product.isLoosed,
            location: product.location,
            purchasePrice: product.purchasePrice,
          );

          scannedProductDetails.add(scanned);
          saveCartProductList(scannedProductDetails);
          afterProductAdding();
        } else {
          qtyIsNotEnough();
        }
      }
    }
  }

  void handleLooseScan({required ProductModel product}) {
    if (product.barcode == null || product.barcode!.isEmpty) {
      return;
    }
    double sellingPrices = (product.sellingPrice ?? 0.0);
    // int looseQuantitys = int.tryParse(looseQuantity.text) ?? 0;
    int looseQuantitys = 0;

    ProductModel scanned = ProductModel(
      barcode: product.barcode,
      name: product.name,
      sellingPrice: sellingPrices,
      quantity: looseQuantitys,
      isLoosed: product.isLoosed,
    );
    scannedProductDetails.add(scanned);
  }

  Future<void> stopCameraAfterDetect(BarcodeCapture barcodes) async {
    barcodeValue.value = barcodes.barcodes.first.rawValue.toString();
    //barcode.text = barcodeValue.value;
    mobileScannerController.stop();
  }
}
