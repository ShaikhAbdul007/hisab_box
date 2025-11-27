import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';

import '../../helper/app_message.dart';
import '../../helper/helper.dart';
import '../../module/category/model/category_model.dart';
import '../../module/inventory/model/product_model.dart';

class ProductController extends GetxController with CacheManager {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final inventoryScanKey = GlobalKey<FormState>();
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  var productList = <ProductModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
  RxList<ProductModel> looseCatogorieList = <ProductModel>[].obs;
  RxList<ProductModel> looseInventoryLis = <ProductModel>[].obs;
  RxList<ProductModel> fullLooseSellingList = <ProductModel>[].obs;
  TextEditingController productName = TextEditingController();
  TextEditingController looseQuantity = TextEditingController();
  TextEditingController looseSellingPrice = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController animalType = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController discount = TextEditingController(text: '0');
  TextEditingController purchasePrice = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController barcode = TextEditingController();
  TextEditingController purchaseDate = TextEditingController();
  TextEditingController exprieDate = TextEditingController();
  TextEditingController loooseProductName = TextEditingController();
  RxBool isFlavorAndWeightNotRequired = true.obs;
  RxBool isLooseProductSave = false.obs;
  RxBool isSaveLoading = false.obs;
  RxString barcodeValue = ''.obs;
  RxString dayDate = ''.obs;
  bool isLoose = false;
  var data = Get.arguments;
  @override
  void onInit() async {
    dayDate.value = setFormateDate();
    barcode.text = data['barcode'];
    barcodeValue.value = barcode.text;
    getCategoryData();
    super.onInit();
  }

  void calculatePurchasePrice() {
    if (sellingPrice.text.isNotEmpty) {
      double sellingPrices = double.tryParse(sellingPrice.text) ?? 0;
      double purchasePrices = sellingPrices - (sellingPrices * 0.20);
      purchasePrice.text = purchasePrices.toStringAsFixed(2);
    }
  }

  void getCategoryData() async {
    await fetchCategories();
    await fetchAnimalCategories();
  }

  Future<void> fetchCategories() async {
    var categorList = await retrieveCategoryModel();
    if (categorList.isNotEmpty) {
      categoryList.value = categorList;
    } else {
      final uid = auth.currentUser?.uid;
      if (uid == null) return;

      try {
        final snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('categories')
                .get();

        categoryList.value =
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return CategoryModel.fromJson(data);
            }).toList();
        saveCategoryModel(categoryList);
      } on FirebaseAuthException catch (e) {
        showMessage(message: e.toString());
      }
    }
  }

  Future<void> fetchAnimalCategories() async {
    var animalCategorList = await retrieveAnimalCategoryModel();
    if (animalCategorList.isNotEmpty) {
      animalTypeList.value = animalCategorList;
    } else {
      final uid = auth.currentUser?.uid;
      if (uid == null) return;
      try {
        final snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('animalCategories')
                .get();
        animalTypeList.value =
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return CategoryModel.fromJson(data);
            }).toList();
        saveAnimalCategoryModel(animalTypeList);
      } on FirebaseAuthException catch (e) {
        showMessage(message: e.toString());
      }
    }
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
      int discounts = int.tryParse(discount.text) ?? 0;
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
        'isFlavorAndWeightNotRequired': isFlavorAndWeightNotRequired.value,
        'location': location.text,
        'discount': discounts,
        'purchaseDate': purchaseDate.text,
        'exprieDate': exprieDate.text,
      });
      fetchAllProducts();
      showMessage(message: scannerDataSave);
      Future.delayed(Duration(milliseconds: 500), () {
        clear();
      });
      Get.back(result: true);
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.message ?? '');
    } catch (e) {
      showMessage(message: somethingWentMessage);
    } finally {
      isSaveLoading.value = false;
    }
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
      // mobileScannerController.start();
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

  Future<void> fetchAllProducts() async {
    final uid = auth.currentUser?.uid;
    final productSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('products')
            .where('quantity')
            .get();
    productList.value =
        productSnapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data()))
            .toList();
    saveProductList(productList.value);
  }

  void clear() {
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

  @override
  void dispose() {
    barcode.dispose();
    productName.dispose();
    looseQuantity.dispose();
    looseSellingPrice.dispose();
    category.dispose();
    sellingPrice.dispose();
    purchasePrice.dispose();
    flavor.dispose();
    weight.dispose();
    quantity.dispose();
    super.dispose();
  }
}
