import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';

import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../../category/model/category_model.dart';
import '../../inventory/model/product_model.dart';

class ProductController extends GetxController with CacheManager {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final box = GetStorage();
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
  TextEditingController level = TextEditingController();
  TextEditingController rack = TextEditingController();
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
  RxBool loosedProduct = false.obs;
  RxString dayDate = ''.obs;
  bool isLoose = false;
  var data = Get.arguments;
  @override
  void onInit() async {
    dayDate.value = setFormateDate();
    setLoosedProduct();
    setBarcode();
    getCategoryData();
    super.onInit();
  }

  void setLoosedProduct() {
    loosedProduct.value = data['flag'];
    if (loosedProduct.value) {
      loooseProductName.text = data['productName'];
      print('your product name is ${data['productName']}');
    }
  }

  void setBarcode() {
    barcode.text = data['barcode'];
    barcodeValue.value = barcode.text;
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

      final String formatDate = setFormateDate();

      final String formaTime = setFormateDate('hh:mm a');

      final productRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('products')
          .doc(barcode);
      final aminalTypeData =
          animalTypeList.firstWhere((e) => e.id == animalType.text).name;
      final categoriesData =
          categoryList.firstWhere((e) => e.id == category.text).name;
      int quantityOnly = int.tryParse(quantity.text) ?? 0;
      int discounts = int.tryParse(discount.text) ?? 0;
      double purchasePrices = double.tryParse(purchasePrice.text) ?? 0.0;
      double sellingPrices = double.tryParse(sellingPrice.text) ?? 0.0;
      await productRef.set({
        'barcode': barcode,
        'name': productName.text,
        'category': categoriesData,
        'animalType': aminalTypeData,
        'isLoose': loosedProduct.value,
        'quantity': quantityOnly,
        'purchasePrice': purchasePrices,
        'sellingPrice': sellingPrices,
        'flavours': flavor.text,
        'weight': weight.text,
        'level': level.text,
        'rack': rack.text,
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
        'isActive': true,
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
      print('');
      showMessage(message: somethingWentMessage);
    } finally {
      isSaveLoading.value = false;
    }
  }

  Future<void> saveNewLooseProduct({required String barcode}) async {
    isLooseProductSave.value = true;

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

    final looseRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('looseProducts')
        .doc(barcode);

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final productSnap = await tx.get(productRef);

        if (!productSnap.exists) {
          throw productNotFound;
        }

        final data = productSnap.data()!;

        // ❌ if not marked looseable → block
        if (data['isLoose'] != true) {
          throw productNotAllowedForLooseSelling;
        }

        final int mainStock = (data['quantity'] ?? 0).toInt();

        if (mainStock <= 0) {
          throw "No sealed pack left";
        }

        // 👇 1 packet → loose
        tx.update(productRef, {
          'quantity': mainStock - 1,
          'updatedDate': formatDate,
          'updatedTime': formaTime,
        });

        final looseQty = int.tryParse(looseQuantity.text) ?? 0;
        if (looseQty <= 0) throw "Loose quantity invalid";

        final looseSnap = await tx.get(looseRef);

        if (looseSnap.exists) {
          final oldQty = (looseSnap['quantity'] ?? 0).toInt();
          tx.update(looseRef, {
            'quantity': oldQty + looseQty,
            'updatedDate': formatDate,
            'updatedTime': formaTime,
            'sellingPrice': double.tryParse(sellingPrice.text) ?? 0.0,
          });
        } else {
          double sellingPrices = double.tryParse(sellingPrice.text) ?? 0.0;
          tx.set(looseRef, {
            'barcode': barcode,
            'name': data['name'],
            'category': data['category'],
            'animalType': data['animalType'],
            'isLoose': true,
            'quantity': looseQty,
            'purchasePrice': data['purchasePrice'],
            'sellingPrice': sellingPrices,
            'flavours': data['flavours'],
            'weight': data['weight'],
            'createdDate': formatDate,
            'updatedDate': formatDate,
            'createdTime': formaTime,
            'updatedTime': formaTime,
            'color': data['color'],
            'level': data['level'],
            'rack': data['rack'],
            'isFlavorAndWeightNotRequired':
                data['isFlavorAndWeightNotRequired'],
            'location': data['location'],
            'discount': data['discount'],
            'purchaseDate': data['purchaseDate'],
            'exprieDate': data['exprieDate'],
          });
        }
      });

      clear();

      Get.back(result: true);
      showMessage(message: "Loose stock created successfully");
    } catch (e) {
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
    saveProductList(productList);
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
