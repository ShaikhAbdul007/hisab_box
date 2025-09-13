import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import '../../../helper/app_message.dart';

class LooseCategoryController extends GetxController {
  TextEditingController name = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController quantity = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final isSaveLoading = false.obs;
  final isFetchDiscount = false.obs;
  final isDeleteDiscount = false.obs;
  RxList<ProductModel> looseCategoryModelList = <ProductModel>[].obs;

  @override
  void onInit() {
    fetchLooseCategory();
    super.onInit();
  }

  Future<void> fetchLooseCategory() async {
    isFetchDiscount.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('looseSellCategory')
              .get();

      looseCategoryModelList.value =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ProductModel.fromJson(data);
          }).toList();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isFetchDiscount.value = false;
    }
  }

  String getRandomHexColor() {
    final random = Random();
    final color = (random.nextDouble() * 0xFFFFFF).toInt();
    return '0xff${color.toRadixString(16).padLeft(6, '0')}';
  }

  Future<void> addLooseProduct() async {
    isSaveLoading.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final looseCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('looseSellCategory');
    try {
      final now = DateTime.now();
      final date = DateFormat('dd-MM-yyyy').format(now);
      final time = DateFormat('hh:mm a').format(now);

      String names = name.text;
      String weights = weight.text;
      double prices = double.parse(price.text);
      String generatedBarcode =
          "${names.replaceAll(" ", "")}-$weights-${now.millisecondsSinceEpoch}";

      await looseCollectionRef.add({
        'barcode': generatedBarcode,
        'name': names,
        'category': 'dry',
        'animalType': 'cat',
        'isLoose': true,
        'purchasePrice': 0.0,
        'sellingPrice': prices,
        'flavours': flavor.text,
        'weight': weights,
        'color': getRandomHexColor(),
        'createdDate': date,
        'updatedDate': date,
        'createdTime': time,
        'updatedTime': time,
        'isLooseCategory': true,
      });
      Get.back();
      showMessage(message: "Loose product saved successfully ✅");
      clear();
      fetchLooseCategory();
    } on FirebaseException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  // Future<void> addDiscount() async {
  //   isSaveLoading.value = true;
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) return;
  //   // final productRef = FirebaseFirestore.instance
  //   //     .collection('users')
  //   //     .doc(uid)
  //   //     .collection('products')
  //   //     .doc(barcode);

  //   final looseCollectionRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .collection('looseProducts');

  //   try {
  //     final now = DateTime.now();
  //     final date = DateFormat('dd-MM-yyyy').format(now);
  //     final time = DateFormat('hh:mm a').format(now);
  //     String names = name.text;
  //     String units = unit.text;
  //     double prices = double.parse(price.text);

  //     await looseCollectionRef.set({
  //       'barcode': barcode,
  //       'name': names,
  //       'category': productData['category'],
  //       'animalType': productData['animalType'],
  //       'isLoose': true,
  //       'quantity': units,
  //       'purchasePrice': '',
  //       'sellingPrice': prices,
  //       'flavours': flavor.text,
  //       'weight': units,
  //       'createdDate': date,
  //       'updatedDate': date,
  //       'createdTime': time,
  //       'updatedTime': time,
  //       // 'color': productData['color'],
  //     });

  //     // await FirebaseFirestore.instance
  //     //     .collection('users')
  //     //     .doc(uid)
  //     //     .collection('looseSellCategory')
  //     //     .add({
  //     //       'name': names,
  //     //       'unit': units,
  //     //       'price': prices,
  //     //       'createdAt': date,
  //     //       'time': time,
  //     //     });
  //     Get.back();
  //     showMessage(message: discountSaveSuccessMessage);
  //     clear();
  //     fetchLooseCategory();
  //   } on FirebaseException catch (e) {
  //     showMessage(message: e.toString());
  //   } finally {
  //     isSaveLoading.value = false;
  //   }
  // }

  Future<void> deleteLooseCategory(String looseCategoryId) async {
    isDeleteDiscount.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('looseSellCategory')
          .doc(looseCategoryId)
          .delete();
      showMessage(message: discountdeleteSuccessMessage);
      fetchLooseCategory();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isDeleteDiscount.value = false;
    }
  }

  clear() {
    name.clear();
    weight.clear();
    price.clear();
  }
}
