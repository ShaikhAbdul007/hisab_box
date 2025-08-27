import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../helper/helper.dart';

class InventroyController extends GetxController {
  var data = Get.arguments;
  bool? flag;
  String? navigate;
  final FirebaseAuth auth = FirebaseAuth.instance;
  RxList<ProductModel> scannedProductDetails = <ProductModel>[].obs;
  List<CategoryModel> categoryList = [];
  List<CategoryModel> animalTypeList = [];
  double totalAmount = 0.0;
  RxString barcodeValue = ''.obs;
  RxString existProductName = ''.obs;
  RxInt stockqty = 0.obs;
  bool isLoose = false;
  RxBool isTreatSelected = false.obs;
  RxBool isCameraStop = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool isProductSaving = false.obs;
  RxBool isLooseProductSave = false.obs;
  RxBool isFlavorAndWeightNotRequired = true.obs;
  RxBool isScannedQtyOutOfStock = false.obs;
  RxInt scannedQty = 0.obs;
  late MobileScannerController mobileScannerController;
  TextEditingController productName = TextEditingController();
  TextEditingController looseQuantity = TextEditingController();
  TextEditingController looseSellingPrice = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController animalType = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController purchasePrice = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController barcode = TextEditingController();
  TextEditingController loooseProductName = TextEditingController();

  @override
  void onInit() {
    getCategoryData();
    flag = data['flag'];
    navigate = data['navigate'];
    mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: [BarcodeFormat.all],
    );

    super.onInit();
  }

  cameraStart() {
    mobileScannerController.start();
    Get.back();
  }

  getCategoryData() async {
    await fetchCategories();
    await fetchAnimalCategories();
  }

  calculatePurchasePrice() {
    if (sellingPrice.text.isNotEmpty) {
      double sellingPrices = double.tryParse(sellingPrice.text) ?? 0;
      double purchasePrices = sellingPrices - (sellingPrices * 0.20);
      purchasePrice.text = purchasePrices.toStringAsFixed(2);
    }
  }

  clear() {
    barcode.clear();
    productName.clear();
    looseQuantity.clear();
    looseSellingPrice.clear();
    category.clear();
    sellingPrice.clear();
    purchasePrice.clear();
    flavor.clear();
    weight.clear();
    quantity.clear();
  }

  String getRandomHexColor() {
    final random = Random();
    final color = (random.nextDouble() * 0xFFFFFF).toInt();
    return '0xff${color.toRadixString(16).padLeft(6, '0')}';
  }

  Future<void> saveNewProduct({required String barcode}) async {
    isSaveLoading.value = true;

    try {
      final uid = auth.currentUser?.uid;
      if (uid == null) return;

      final now = DateTime.now();
      final String formatDate = DateFormat('dd-MM-yyyy').format(now);
      final String formaTime = DateFormat('hh:mm a').format(now);

      final productRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('products')
          .doc(barcode);
      final aminalTypeData = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('animalCategories')
          .doc(animalType.text);
      final categoriesData = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('categories')
          .doc(category.text);

      final animalexistingDoc = await aminalTypeData.get();
      final categories = await categoriesData.get();

      int quantityOnly = int.tryParse(quantity.text) ?? 0;
      await productRef.set({
        'barcode': barcode,
        'name': productName.text,
        'category': categories['name'],
        'animalType': animalexistingDoc['name'],
        'isLoose': isLoose,
        'quantity': quantityOnly,
        'purchasePrice': double.tryParse(purchasePrice.text) ?? 0,
        'sellingPrice': double.tryParse(sellingPrice.text) ?? 0.0,
        'flavours': flavor.text,
        'weight': weight.text,
        'createdDate': formatDate,
        'updatedDate': formatDate,
        'createdTime': formaTime,
        'updatedTime': formaTime,
        'color': getRandomHexColor(),
      });

      showMessage(message: scannerDataSave);

      Future.delayed(Duration(milliseconds: 500), () {
        clear();
        cameraStart();
      });
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.message ?? '');
    } catch (e) {
      showMessage(message: somethingWentMessage);
    } finally {
      isSaveLoading.value = false;
    }
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
      loooseProductName.text = product.name ?? '';
      return (true, product);
    }
    return (false, product);
  }

  Future<void> fetchCategories() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('categories')
              .get();

      categoryList =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return CategoryModel.fromJson(data);
          }).toList();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    }
  }

  Future<void> fetchAnimalCategories() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('animalCategories')
              .get();

      animalTypeList =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return CategoryModel.fromJson(data);
          }).toList();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    }
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
      if (isLoose) {
        return true;
      }
      return false;
    } else {
      return false;
    }
  }

  void handleScan({
    required ProductModel product,
    required Function() afterProductAdding,
    required Function() qtyIsNotEnough,
  }) {
    // Check ki barcode valid hai ya nahi
    if (product.barcode == null || product.barcode!.isEmpty) return;

    final index = scannedProductDetails.indexWhere(
      (p) => p.barcode == product.barcode,
    );

    if (index != -1) {
      // Product already scanned → qty badhane ka logic
      if (scannedProductDetails[index].quantity! < (product.quantity ?? 0)) {
        scannedProductDetails[index].quantity =
            (scannedProductDetails[index].quantity ?? 0) + 1;
        scannedQty.value = scannedProductDetails[index].quantity!;
        afterProductAdding();
      } else {
        // Database ki quantity se zyada scan nahi kar sakte
        qtyIsNotEnough();
      }
    } else {
      // naya product hai → list me add karo with qty = 1
      if ((product.quantity ?? 0) > 0) {
        ProductModel scanned = ProductModel(
          barcode: product.barcode,
          name: product.name,
          sellingPrice: product.sellingPrice,
          quantity: 1,
        );
        scannedProductDetails.add(scanned);

        afterProductAdding();
      } else {
        // Agar database me stock hi khatam hai
        qtyIsNotEnough();
      }
    }
  }

  void handleLooseScan({
    required ProductModel product,
    void Function()? afterProductAdding,
  }) {
    if (product.barcode == null || product.barcode!.isEmpty) {
      return;
    }
    double pricePerPiece =
        (product.sellingPrice ?? 0.0) / (product.perpiece ?? 1);
    ProductModel scanned = ProductModel(
      barcode: product.barcode,
      name: product.name,
      sellingPrice: pricePerPiece,
      quantity: 1,
    );
    scannedProductDetails.add(scanned);
    totalAmount += pricePerPiece;
    afterProductAdding!();
  }

  Future<void> saveNewLooseProduct({required String barcode}) async {
    isLooseProductSave.value = true;
    final now = DateTime.now();
    final String formatDate = DateFormat('dd-MM-yyyy').format(now);
    final String formaTime = DateFormat('hh:mm a').format(now);
    final uid = auth.currentUser?.uid;

    final productRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('products')
        .doc(barcode);

    final looseCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('looseProducts')
        .doc(barcode);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final productSnap = await transaction.get(productRef);
        if (!productSnap.exists) {
          throw Exception("Product not found");
        }
        final data = productSnap.data()!;
        final quantity = (data['quantity'] ?? 0) as int;
        if (quantity <= 0) {
          throw Exception("Insufficient stock");
        }
        transaction.update(productRef, {'quantity': quantity - 1});
      });
      final looseSnap = await looseCollectionRef.get();
      final productData = await productRef.get();

      if (looseSnap.exists) {
        throw Exception("Product already exists in loose stock");
      }
      await looseCollectionRef.set({
        'barcode': barcode,
        'name': productData['name'],
        'category': productData['category'],
        'animalType': productData['animalType'],
        'isLoose': productData['isLoose'],
        'quantity': int.tryParse(looseQuantity.text) ?? 0,
        'purchasePrice': productData['purchasePrice'],
        'sellingPrice': double.tryParse(sellingPrice.text) ?? 0.0,
        'flavours': productData['flavours'],
        'weight': productData['weight'],
        'createdDate': formatDate,
        'updatedDate': formatDate,
        'createdTime': formaTime,
        'updatedTime': formaTime,
        'color': productData['color'],
      });
      clear();
      Get.back();
      mobileScannerController.start();
      showMessage(message: 'Product added to loose stock');
    } on FirebaseException catch (e) {
      Get.back();
      showMessage(message: e.message ?? "Firebase Error");
    } catch (e) {
      Get.back();
      showMessage(message: e.toString());
    } finally {
      isLooseProductSave.value = false;
    }
  }

  Future<void> stopCameraAfterDetect(BarcodeCapture barcodes) async {
    barcodeValue.value = barcodes.barcodes.first.rawValue.toString();
    barcode.text = barcodeValue.value;
    mobileScannerController.stop();
  }
}
