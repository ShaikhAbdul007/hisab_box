import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';

import '../../../helper/helper.dart';
import '../../../helper/set_format_date.dart';
import '../../category/model/category_model.dart';
import '../../inventory/model/product_model.dart';

class ProductDetailsController extends GetxController with CacheManager {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final inventoryScanKey = GlobalKey<FormState>();
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
  RxList<ProductModel> looseCatogorieList = <ProductModel>[].obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<ProductModel> looseInventoryLis = <ProductModel>[].obs;
  RxList<ProductModel> fullLooseSellingList = <ProductModel>[].obs;
  TextEditingController productName = TextEditingController();
  TextEditingController looseQuantity = TextEditingController();
  TextEditingController looseSellingPrice = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController animalType = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController purchasePrice = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController barcode = TextEditingController();
  TextEditingController loooseProductName = TextEditingController();
  TextEditingController exprieDate = TextEditingController();
  TextEditingController purchaseDate = TextEditingController();
  RxList<CategoryModel> categoryModel = <CategoryModel>[].obs;
  RxBool isFlavorAndWeightNotRequired = true.obs;
  RxBool isLooseProductSave = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool readOnly = true.obs;
  RxBool dropDownReadOnly = false.obs;
  RxString barcodeValue = ''.obs;
  RxString dayDate = ''.obs;
  bool isLoose = false;
  var data = Get.arguments;

  @override
  void onInit() {
    dayDate.value = setFormateDate();
    setData();
    getCategoryData();
    super.onInit();
  }

  void getCategoryData() async {
    await fetchCategories();
    await fetchAnimalCategories();
  }

  void setData() {
    category.text = data['product'].category ?? '';
    animalType.text = data['product'].animalType ?? '';
    isFlavorAndWeightNotRequired.value =
        data['product'].isFlavorAndWeightNotRequired ?? false;
    productName.text = data['product'].name ?? '';
    barcode.text = data['product'].barcode ?? '';
    quantity.text = data['product'].quantity.toString();
    sellingPrice.text = data['product'].sellingPrice.toString();
    purchasePrice.text = data['product'].purchasePrice.toString();
    flavor.text = data['product'].flavor ?? '';
    weight.text = data['product'].weight.toString();
    isLoose = data['product'].isLoosed ?? false;
    location.text = data['product'].location ?? '';
    discount.text = data['product'].discount.toString();
    purchaseDate.text = data['product'].purchaseDate ?? '';
    exprieDate.text = data['product'].expireDate ?? '';
  }

  void updateProductQuantity({
    required String barcode,
    required bool isLoosed,
  }) async {
    isSaveLoading.value = true;
    try {
      final String formatDate = setFormateDate();
      final uid = auth.currentUser?.uid;
      if (uid == null) return;
      var categoryItem = categoryList.firstWhereOrNull(
        (e) => e.id == category.text,
      );
      var animalCategoryItem = animalTypeList.firstWhereOrNull(
        (e) => e.id == animalType.text,
      );
      var categoryName = categoryItem?.name ?? category.text;
      var animalCategoryName = animalCategoryItem?.name ?? animalType.text;
      customMessageOrErrorPrint(message: categoryName);
      customMessageOrErrorPrint(message: animalCategoryName);
      if (isLoosed) {
        final looseProductRef = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('looseProducts')
            .doc(barcode);
        final looseProductExistingDoc = await looseProductRef.get();

        int discounts = int.tryParse(discount.text) ?? 0;
        if (looseProductExistingDoc.exists) {
          await looseProductRef.update({
            'quantity': int.parse(quantity.text),
            'purchasePrice': double.tryParse(purchasePrice.text) ?? 0.0,
            'sellingPrice': double.tryParse(sellingPrice.text) ?? 0.0,
            'name': productName.text,
            'flavours': flavor.text,
            'isLoose': isLoose,
            'isFlavorAndWeightNotRequired': isFlavorAndWeightNotRequired.value,
            'location': location.text,
            'discount': discounts,
            'weight': weight.text,
            'category': categoryName,
            'animalType': animalCategoryName,
            'purchaseDate': purchaseDate.text,
            'exprieDate': exprieDate.text,
            'updatedDate': formatDate,
            'updatedTime': setFormateDate('hh:mm a'),
          });
          await fetchLooseProduct();
          Get.back(result: true);
          showMessage(message: '✅ Loosed Product Info updated.');
        }
      } else {
        final productRef = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('products')
            .doc(barcode);
        final existingDoc = await productRef.get();
        int discounts = int.tryParse(discount.text) ?? 0;
        if (existingDoc.exists) {
          await productRef.update({
            'quantity': int.parse(quantity.text),
            'purchasePrice': double.tryParse(purchasePrice.text) ?? 0.0,
            'sellingPrice': double.tryParse(sellingPrice.text) ?? 0.0,
            'name': productName.text,
            'flavours': flavor.text,
            'isLoose': isLoose,
            'isFlavorAndWeightNotRequired': isFlavorAndWeightNotRequired.value,
            'location': location.text,
            'discount': discounts,
            'weight': weight.text,
            'category': categoryName,
            'animalType': animalCategoryName,
            'purchaseDate': purchaseDate.text,
            'exprieDate': exprieDate.text,
            'updatedDate': formatDate,
            'updatedTime': setFormateDate('hh:mm a'),
          });
          await fetchAllProducts();
          Get.back(result: true);
          showMessage(message: '✅ Product Info updated.');
        }
      }
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  CategoryModel? getSelectedCategory({
    required String categorysId,
    String categoryType = '',
  }) {
    final name = categorysId;
    try {
      if (categoryType == 'animal') {
        return animalTypeList.firstWhere((e) {
          return e.name == name;
        });
      } else {
        return categoryList.firstWhere((e) {
          return e.name == name;
        });
      }
    } catch (_) {
      return null;
    }
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

  Future<void> fetchAllProducts() async {
    final uid = auth.currentUser?.uid;
    final productSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('products')
            .where('isActive', isEqualTo: true)
            .get();
    productList.value =
        productSnapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data()))
            .toList();
    saveProductList(productList);
  }

  Future<void> fetchLooseProduct() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('looseProducts')
              .get();

      snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return LooseInvetoryModel.fromJson(data);
      }).toList();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    } finally {}
  }
}
