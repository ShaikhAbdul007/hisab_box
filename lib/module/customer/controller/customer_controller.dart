import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/order_complete/controller/order_controller.dart';

import '../../order_complete/model/customer_details_model.dart';

// class CustomerController extends GetxController with CacheManager {
//   final _auth = FirebaseAuth.instance;
//   var orderController = Get.put(OrderController());
//   RxBool customDataLoading = false.obs;
//   RxString searchText = ''.obs;
//   RxList<CustomerDetails> customerDetailList = <CustomerDetails>[].obs;
//   TextEditingController searchController = TextEditingController();

//   @override
//   void onInit() {
//     fetchAllCustomers();
//     super.onInit();
//   }

//   void searchProduct(String value) {
//     searchText.value = value;
//     searchController.text = value;
//   }

//   void clear() {
//     searchController.clear();
//     searchText.value = '';
//   }

//   double calculateTotalCredit(CustomerDetails customer) {
//     return customer.totalCredit;
//   }

//   Future<void> fetchAllCustomers() async {
//     customDataLoading.value = true;
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) {
//       customDataLoading.value = false;
//       return;
//     }
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(uid)
//               .collection('customers')
//               .get();
//       final customers =
//           snapshot.docs
//               .map((doc) => CustomerDetails.fromJson(doc.data()))
//               .toList();
//       customerDetailList.value = customers;
//     } catch (e) {
//       print("Fetch customers error: $e");
//       showMessage(message: e.toString());
//     } finally {
//       customDataLoading.value = false;
//     }
//   }
// }

class CustomerController extends GetxController with CacheManager {
  final _auth = FirebaseAuth.instance;
  var orderController = Get.put(OrderController());
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

  double calculateTotalCredit(CustomerDetails customer) {
    return customer.totalCredit;
  }

  // ================= CACHE FIRST =================
  Future<void> fetchAllCustomers() async {
    customDataLoading.value = true;

    // 🔥 1️⃣ LOAD FROM CACHE FIRST
    final cacheCustomers = await retrieveCustomerList();
    if (cacheCustomers.isNotEmpty) {
      customerDetailList.value = cacheCustomers;
    }

    // 🔥 2️⃣ FETCH FROM FIREBASE (SYNC)
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      customDataLoading.value = false;
      return;
    }

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('customers')
              .get();

      final customers =
          snapshot.docs
              .map((doc) => CustomerDetails.fromJson(doc.data()))
              .toList();

      // 🔥 UPDATE UI + CACHE
      customerDetailList.value = customers;
      saveCustomerList(customers);
    } catch (e) {
      print("Fetch customers error: $e");
      showMessage(message: e.toString());
    } finally {
      customDataLoading.value = false;
    }
  }
}
