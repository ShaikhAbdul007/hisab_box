import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/order_complete/model/customer_details_model.dart';

import '../../../helper/helper.dart';

// class CredtiController extends GetxController with CacheManager {
//   final uid = FirebaseAuth.instance.currentUser?.uid;

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

//   /// ⚡ INSTANT – no invoice scan
//   double calculateTotalCredit(CustomerDetails customer) {
//     return customer.totalCredit; // 🔥 already pre-calculated in Firestore
//   }

//   Future<void> fetchAllCustomers() async {
//     try {
//       customDataLoading.value = true;

//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(uid)
//               .collection('customers')
//               .where('totalCredit', isGreaterThan: 0) // 🔥 only dues customers
//               .orderBy('totalCredit', descending: true)
//               .get();

//       customerDetailList.value =
//           snapshot.docs
//               .map((doc) => CustomerDetails.fromJson(doc.data()))
//               .toList();
//     } catch (e) {
//       customMessageOrErrorPrint(message: "Fetch customers error: $e");
//       customerDetailList.clear();
//     } finally {
//       customDataLoading.value = false;
//     }
//   }
// }

class CredtiController extends GetxController with CacheManager {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  RxBool customDataLoading = false.obs;
  RxString searchText = ''.obs;
  RxList<CustomerDetails> customerDetailList = <CustomerDetails>[].obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    fetchAllCustomers(); // 👈 cache-first
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
    return customer.totalCredit;
  }

  // ===================================================
  // 🔥 CACHE FIRST → FIREBASE FALLBACK
  // ===================================================
  Future<void> fetchAllCustomers() async {
    try {
      customDataLoading.value = true;

      // 1️⃣ LOAD FROM CACHE
      final cacheList = await retrieveCustomerList();
      if (cacheList.isNotEmpty) {
        customerDetailList.value =
            cacheList.where((c) => c.totalCredit > 0).toList()
              ..sort((a, b) => b.totalCredit.compareTo(a.totalCredit));

        return;
      }

      // 2️⃣ FIREBASE (ONLY IF CACHE EMPTY)
      if (uid == null) {
        customerDetailList.clear();
        return;
      }

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('customers')
              .where('totalCredit', isGreaterThan: 0)
              .orderBy('totalCredit', descending: true)
              .get();

      final list =
          snapshot.docs
              .map((doc) => CustomerDetails.fromJson(doc.data()))
              .toList();

      customerDetailList.value = list;

      // 3️⃣ SAVE TO CACHE (FULL CUSTOMER LIST)
      // ⚠️ cache me sirf credit wale nahi,
      // poori list jati hai (future reuse ke liye)
      final fullSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('customers')
              .get();

      final fullList =
          fullSnapshot.docs
              .map((e) => CustomerDetails.fromJson(e.data()))
              .toList();

      saveCustomerList(fullList);
    } catch (e) {
      customMessageOrErrorPrint(message: "Fetch customers error: $e");
      customerDetailList.clear();
    } finally {
      customDataLoading.value = false;
    }
  }
}
