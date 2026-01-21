import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/order_complete/model/customer_details_model.dart';

import '../../sell/model/print_model.dart';

// class OrderController extends GetxController {
//   final uid = FirebaseAuth.instance.currentUser?.uid;
//   TextEditingController mobileNumber = TextEditingController();
//   TextEditingController name = TextEditingController();
//   TextEditingController address = TextEditingController();
//   TextEditingController description = TextEditingController();
//   RxList<CustomerDetails> customerDetails = <CustomerDetails>[].obs;
//   RxBool saveCustomerWithInvoiceLoading = false.obs;
//   RxBool homeButtonVisible = true.obs;
//   var data = Get.arguments;

//   @override
//   void onInit() {
//     loadAllCustomers();
//     if (data != null) {
//       setButtonValue();
//     }
//     super.onInit();
//   }

//   void setButtonValue() {
//     if (data.payment.credit != 0.0) {
//       homeButtonVisible.value = false;
//     }
//   }

//   Future<List<CustomerDetails>> loadAllCustomers() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;

//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(uid)
//             .collection('customers')
//             .get();

//     customerDetails.value =
//         snapshot.docs.map((e) {
//           return CustomerDetails(
//             id: e.id,
//             name: e["name"] ?? "",
//             mobile: e["mobile"] ?? "",
//             address: e["address"] ?? "",
//           );
//         }).toList();

//     return customerDetails;
//   }

//   Future<bool> saveCustomerWithInvoice({
//     required PrintInvoiceModel invoice,
//   }) async {
//     saveCustomerWithInvoiceLoading.value = true;
//     try {
//       final ref = FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .collection('customers')
//           .doc(mobileNumber.text);
//       final doc = await ref.get();
//       if (doc.exists) {
//         await ref.update({
//           "name": name.text,
//           "address": address.text,
//           "mobile": mobileNumber.text,
//           'description': description.text,
//           "updatedAt": DateTime.now().toIso8601String(),
//           "invoices": FieldValue.arrayUnion([invoice.toJson()]),
//         });

//         return true;
//       } else {
//         await ref.set({
//           "name": name.text,
//           "address": address.text,
//           "mobile": mobileNumber.text,
//           'description': description.text,
//           "createdAt": DateTime.now().toIso8601String(),
//           "invoices": [invoice.toJson()],
//         });
//         return true;
//       }
//     } catch (e) {
//       return false;
//     } finally {
//       saveCustomerWithInvoiceLoading.value = false;
//     }
//   }

//   void setDataAsPerOptionSelecte(CustomerDetails option) {
//     address.text = option.address ?? '';
//     name.text = option.name ?? '';
//     mobileNumber.text = option.mobile ?? '';
//   }

//   void clear() {
//     name.clear();
//     address.clear();
//     mobileNumber.clear();
//     description.clear();
//   }
// }

class OrderController extends GetxController with CacheManager {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  TextEditingController mobileNumber = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController description = TextEditingController();

  RxList<CustomerDetails> customerDetails = <CustomerDetails>[].obs;

  RxBool saveCustomerWithInvoiceLoading = false.obs;
  RxBool homeButtonVisible = true.obs;

  var data = Get.arguments;

  @override
  void onInit() {
    loadAllCustomers(); // 👈 cache-first
    if (data != null) {
      setButtonValue();
    }
    super.onInit();
  }

  void setButtonValue() {
    if (data.payment.credit != 0.0) {
      homeButtonVisible.value = false;
    }
  }

  // ===============================
  // 🔥 CACHE-FIRST CUSTOMER LOAD
  // ===============================
  Future<List<CustomerDetails>> loadAllCustomers() async {
    // 1️⃣ LOAD FROM CACHE
    final cacheList = await retrieveCustomerList();
    if (cacheList.isNotEmpty) {
      customerDetails.value = cacheList;
      return customerDetails;
    }

    // 2️⃣ FALLBACK TO FIREBASE
    if (uid == null) return [];

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('customers')
            .get();

    final list =
        snapshot.docs.map((e) {
          return CustomerDetails(
            id: e.id,
            name: e["name"] ?? "",
            mobile: e["mobile"] ?? "",
            address: e["address"] ?? "",
            //  totalPurchase: (e["totalPurchase"] ?? 0).toDouble(),
            totalPaid: (e["totalPaid"] ?? 0).toDouble(),
            totalCredit: (e["totalCredit"] ?? 0).toDouble(),
            createdAt: e["createdAt"],
          );
        }).toList();

    customerDetails.value = list;

    // 3️⃣ SAVE TO CACHE
    saveCustomerList(list);

    return list;
  }

  // ===============================
  // 🔥 SAVE + CACHE SYNC
  // ===============================
  Future<bool> saveCustomerWithInvoice({
    required PrintInvoiceModel invoice,
  }) async {
    saveCustomerWithInvoiceLoading.value = true;
    try {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('customers')
          .doc(mobileNumber.text);

      final doc = await ref.get();

      if (doc.exists) {
        await ref.update({
          "name": name.text,
          "address": address.text,
          "mobile": mobileNumber.text,
          "description": description.text,
          "updatedAt": DateTime.now().toIso8601String(),
          "invoices": FieldValue.arrayUnion([invoice.toJson()]),
        });
      } else {
        await ref.set({
          "name": name.text,
          "address": address.text,
          "mobile": mobileNumber.text,
          "description": description.text,
          "createdAt": DateTime.now().toIso8601String(),
          "invoices": [invoice.toJson()],
          "totalPurchase": 0,
          "totalPaid": 0,
          "totalCredit": invoice.payment?.credit ?? 0,
        });
      }

      // 🔁 REFRESH CACHE AFTER SAVE
      await loadAllCustomers();

      return true;
    } catch (e) {
      return false;
    } finally {
      saveCustomerWithInvoiceLoading.value = false;
    }
  }

  void setDataAsPerOptionSelecte(CustomerDetails option) {
    address.text = option.address ?? '';
    name.text = option.name ?? '';
    mobileNumber.text = option.mobile ?? '';
  }

  void clear() {
    name.clear();
    address.clear();
    mobileNumber.clear();
    description.clear();
  }
}
