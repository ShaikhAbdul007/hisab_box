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
    searchController.text = searchText.value;
  }

  void clear() {
    searchController.clear();
    searchText.value = '';
  }

  double calculateTotalCredit(CustomerDetails customer) {
    if (customer.invoices == null || customer.invoices!.isEmpty) return 0;

    double total = 0;

    for (var invoice in customer.invoices!) {
      total += (invoice.payment?.credit ?? 0).toDouble();
    }

    return total;
  }

  Future<List<CustomerDetails>> fetchAllCustomers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('customers')
              .orderBy('createdAt', descending: true)
              .get();

      customerDetailList.value =
          snapshot.docs
              .map((doc) => CustomerDetails.fromJson(doc.data()))
              .toList();
      return customerDetailList;
    } catch (e) {
      customMessageOrErrorPrint(message: "Fetch customers error: $e");
      return customerDetailList.value = [];
    }
  }
}
