import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

import '../../../helper/helper.dart';
import '../../category/model/category_model.dart';

class GenerateBarcodeController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
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
  bool isLoose = false;
  RxBool isSaveLoading = false.obs;
  RxBool isFlavorAndWeightNotRequired = true.obs;

  @override
  void onInit() {
    getCategoryDataAndAnimalData();
    super.onInit();
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

  getCategoryDataAndAnimalData() async {
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

      categoryList.value =
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

      animalTypeList.value =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return CategoryModel.fromJson(data);
          }).toList();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    }
  }
}
