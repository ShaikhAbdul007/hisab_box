import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/helper/helper.dart';
import '../../../helper/app_message.dart';
import '../model/loose_category_model.dart';

class LooseCategoryController extends GetxController {
  TextEditingController name = TextEditingController();
  TextEditingController unit = TextEditingController();
  TextEditingController price = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final isSaveLoading = false.obs;
  final isFetchDiscount = false.obs;
  final isDeleteDiscount = false.obs;
  RxList<LooseCategoryModel> looseCategoryModelList =
      <LooseCategoryModel>[].obs;

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
            return LooseCategoryModel.fromJson(data);
          }).toList();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isFetchDiscount.value = false;
    }
  }

  Future<void> addDiscount() async {
    isSaveLoading.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final now = DateTime.now();
      final date = DateFormat('dd-MM-yyyy').format(now);
      final time = DateFormat('hh:mm a').format(now);
      String names = name.text;
      String units = unit.text;
      int prices = int.parse(price.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('looseSellCategory')
          .add({
            'name': names,
            'unit': units,
            'price': prices,
            'createdAt': date,
            'time': time,
          });
      Get.back();
      showMessage(message: discountSaveSuccessMessage);
      clear();
      fetchLooseCategory();
    } on FirebaseException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

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
    unit.clear();
    price.clear();
  }
}
