import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/helper/helper.dart';
import '../../../helper/app_message.dart';
import '../model/discount_model.dart';

class DiscountController extends GetxController {
  TextEditingController discountPercentage = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final isSaveLoading = false.obs;
  final isFetchDiscount = false.obs;
  final isDeleteDiscount = false.obs;
  RxList<DiscountModel> discountList = <DiscountModel>[].obs;

  @override
  void onInit() {
    fetchDiscounts();
    super.onInit();
  }

  Future<void> fetchDiscounts() async {
    isFetchDiscount.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('discounts')
              .get();

      discountList.value =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return DiscountModel.fromJson(data);
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
      final label = int.parse(discountPercentage.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('discounts')
          .add({'label': label, 'createdAt': date, 'time': time});
      Get.back();
      showMessage(message: discountSaveSuccessMessage);
      clear();
      fetchDiscounts();
    } on FirebaseException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  Future<void> deleteDiscount(String discountId) async {
    isDeleteDiscount.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('discounts')
          .doc(discountId)
          .delete();
      showMessage(message: discountdeleteSuccessMessage);
      fetchDiscounts();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isDeleteDiscount.value = false;
    }
  }

  clear() {
    discountPercentage.clear();
  }
}
