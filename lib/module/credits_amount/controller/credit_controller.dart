import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/module/order_complete/model/customer_details_model.dart';

import '../../../helper/helper.dart';

class CredtiController extends GetxController {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  RxBool customDataLoading = false.obs;
  RxString searchText = ''.obs;
  RxList<CustomerDetails> customerDetailList = <CustomerDetails>[].obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    fetchAllCustomers();
    super.onInit();
  }

  void searchProduct(String value) {
    searchText.value = value;
    searchController.text = value;
  }

  void clear() {
    searchController.clear();
    searchText.value = '';
  }

  /// ⚡ INSTANT – no invoice scan
  double calculateTotalCredit(CustomerDetails customer) {
    return customer.totalCredit; // 🔥 already pre-calculated in Firestore
  }

  Future<void> fetchAllCustomers() async {
    try {
      customDataLoading.value = true;

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('customers')
              .where('totalCredit', isGreaterThan: 0) // 🔥 only dues customers
              .orderBy('totalCredit', descending: true)
              .get();

      customerDetailList.value =
          snapshot.docs
              .map((doc) => CustomerDetails.fromJson(doc.data()))
              .toList();
    } catch (e) {
      customMessageOrErrorPrint(message: "Fetch customers error: $e");
      customerDetailList.clear();
    } finally {
      customDataLoading.value = false;
    }
  }
}
