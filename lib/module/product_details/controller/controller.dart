import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';

import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../../category/model/category_model.dart';
import '../../inventory/model/product_model.dart';

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
      AppLogger.debug(
        'Product name set: ${data['productName']}',
        'ProductController',
      );
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

      String? collectionName;
      bool isGodown = location.text.toLowerCase() == 'godown';
      if (isGodown) {
        collectionName = 'godownProducts';
      } else {
        collectionName = 'products'; // Default to shop
      }

      final productRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(collectionName)
          .doc(barcode);

      final aminalTypeData =
          animalTypeList.firstWhere((e) => e.id == animalType.text).name;
      final categoriesData =
          categoryList.firstWhere((e) => e.id == category.text).name;
      int quantityOnly = int.tryParse(quantity.text) ?? 0;
      int discounts = int.tryParse(discount.text) ?? 0;
      double purchasePrices = double.tryParse(purchasePrice.text) ?? 0.0;
      double sellingPrices = double.tryParse(sellingPrice.text) ?? 0.0;

      // 🔥 CREATE NEW PRODUCT MODEL
      final newProduct = ProductModel(
        barcode: barcode,
        name: productName.text,
        category: categoriesData,
        animalType: aminalTypeData,
        isLoosed: loosedProduct.value,
        quantity: quantityOnly,
        purchasePrice: purchasePrices,
        sellingPrice: sellingPrices,
        flavor: flavor.text,
        weight: weight.text,
        level: level.text,
        rack: rack.text,
        createdDate: formatDate,
        updatedDate: formatDate,
        createdTime: formaTime,
        updatedTime: formaTime,
        color: getRandomHexColor(),
        isFlavorAndWeightNotRequired: isFlavorAndWeightNotRequired.value,
        location: location.text,
        discount: discounts,
        purchaseDate: purchaseDate.text,
        expireDate: exprieDate.text,
        isActive: true,
        sellType: 'packet',
      );

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
        'sellType': 'packet',
      });

      // 🔥 PROPER CACHE UPDATE INSTEAD OF CLEAR
      if (isGodown) {
        // Update godown cache
        final godownList = retrieveGodownProductList();
        godownList.add(newProduct);
        saveGodownProductList(godownList);
      } else {
        // Update shop cache
        final shopList = await retrieveProductList();
        shopList.add(newProduct);
        saveProductList(shopList);
      }

      // 🔥 UPDATE DASHBOARD CACHE
      //  recalculateInventoryDashboardOnly();
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

    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    final String formatDate = setFormateDate();
    final String formatTime = setFormateDate('hh:mm a');

    final int looseQty = int.tryParse(looseQuantity.text) ?? 0;
    final double looseSellingPrice = double.tryParse(sellingPrice.text) ?? 0.0;

    if (looseQty <= 0) {
      showMessage(message: "❌ Invalid loose quantity");
      isLooseProductSave.value = false;
      return;
    }

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
        /// ===============================
        /// 1️⃣ READS FIRST (MANDATORY)
        /// ===============================
        final productSnap = await tx.get(productRef);
        final looseSnap = await tx.get(looseRef);

        if (!productSnap.exists) {
          throw Exception(
            "Product not found Or Product not found in SHOP. Move to shop first!",
          );
        }

        final data = productSnap.data() as Map<String, dynamic>;

        final bool allowLoose = data['isLoose'] == true;

        final String productLocation =
            data['location']?.toString().toLowerCase() ?? '';
        if (productLocation != 'shop') {
          throw Exception("Loose selling only allowed for SHOP products!");
        }

        if (!allowLoose) {
          throw Exception("Product not allowed for loose selling");
        }

        final int mainStock = (data['quantity'] ?? 0).toInt();
        if (mainStock <= 0) {
          throw Exception("No sealed pack left SHOP");
        }

        final int looseQty = int.tryParse(looseQuantity.text) ?? 0;
        if (looseQty <= 0) {
          throw Exception("Invalid loose quantity");
        }

        /// ===============================
        /// 2️⃣ WRITES AFTER ALL READS
        /// ===============================

        // 🔻 Deduct packet stock
        tx.update(productRef, {
          'quantity': mainStock - 1,
          'updatedDate': formatDate,
          'updatedTime': formatTime,
        });

        if (looseSnap.exists) {
          final looseData = looseSnap.data() as Map<String, dynamic>;
          final int oldQty = (looseData['quantity'] ?? 0).toInt();
          tx.update(looseRef, {
            'quantity': oldQty + looseQty,
            'sellingPrice': looseSellingPrice,
            'updatedDate': formatDate,
            'updatedTime': formatTime,
          });
        } else {
          tx.set(looseRef, {
            'barcode': barcode,
            'name': data['name'],
            'category': data['category'],
            'animalType': data['animalType'],
            'quantity': looseQty,
            'purchasePrice': data['purchasePrice'],
            'sellingPrice': looseSellingPrice,
            'weight': data['weight'],
            'color': data['color'],
            'level': data['level'],
            'rack': data['rack'],
            'location': data['location'],
            'discount': data['discount'],
            'isFlavorAndWeightNotRequired':
                data['isFlavorAndWeightNotRequired'],
            'createdDate': formatDate,
            'createdTime': formatTime,
            'updatedDate': formatDate,
            'updatedTime': formatTime,
            'exprieDate': data['exprieDate'],
            'purchaseDate': data['purchaseDate'],
            'isActive': true,
            'sellType': 'loose',
          });
        }
      });

      // 🔥 UPDATE CACHE AFTER TRANSACTION SUCCESS
      // Update shop product cache (quantity decreased)
      final shopList = await retrieveProductList();
      final shopIndex = shopList.indexWhere((p) => p.barcode == barcode);
      if (shopIndex != -1) {
        shopList[shopIndex].quantity = (shopList[shopIndex].quantity ?? 0) - 1;
        saveProductList(shopList);
      }

      // Update loose product cache
      final looseList = await retrieveLoosedProductList();
      final looseIndex = looseList.indexWhere((p) => p.barcode == barcode);
      if (looseIndex != -1) {
        // Update existing loose product
        looseList[looseIndex].quantity =
            (looseList[looseIndex].quantity ?? 0) + looseQty;
        looseList[looseIndex].sellingPrice = looseSellingPrice;
      } else {
        // Add new loose product to cache
        final productData = shopList.firstWhere((p) => p.barcode == barcode);
        final newLooseProduct = LooseInvetoryModel(
          barcode: barcode,
          name: productData.name,
          category: productData.category,
          animalType: productData.animalType,
          quantity: looseQty,
          purchasePrice: productData.purchasePrice,
          sellingPrice: looseSellingPrice,
          weight: productData.weight,
          color: productData.color,
          level: productData.level,
          rack: productData.rack,
          location: productData.location,
          discount: productData.discount,
          isFlavorAndWeightNotRequired:
              productData.isFlavorAndWeightNotRequired,
          createdDate: formatDate,
          createdTime: formatTime,
          updatedDate: formatDate,
          updatedTime: formatTime,
          expireDate: productData.expireDate,
          purchaseDate: productData.purchaseDate,
          isActive: true,
          sellType: 'loose',
        );
        looseList.add(newLooseProduct);
      }
      saveLoosedProductList(looseList);

      // 🔥 UPDATE DASHBOARD CACHE
      recalculateInventoryDashboardOnly();

      clear();
      Get.back(result: true);
      showMessage(message: "✅ Loose stock created successfully");
    } on FirebaseException catch (e) {
      AppLogger.error(
        "Firebase error while creating loose stock",
        e,
        "ProductController",
      );
      showMessage(message: "❌ ${e.toString()}");
    } catch (e) {
      AppLogger.error("Error creating loose stock", e, "ProductController");
      showMessage(message: "❌ ${e.toString()}");
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
            .where('isActive', isEqualTo: true)
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
