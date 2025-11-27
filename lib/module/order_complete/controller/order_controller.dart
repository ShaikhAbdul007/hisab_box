import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/order_complete/model/customer_details_model.dart';

import '../../sell/model/print_model.dart';

class OrderController extends GetxController {
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  RxList<CustomerDetails> customerDetails = <CustomerDetails>[].obs;
  RxBool saveCustomerWithInvoiceLoading = false.obs;
  var data = Get.arguments;

  @override
  void onInit() {
    loadAllCustomers();
    super.onInit();
  }

  Future<List<CustomerDetails>> loadAllCustomers() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('customers')
            .get();

    customerDetails.value =
        snapshot.docs.map((e) {
          return CustomerDetails(
            id: e.id,
            name: e["name"] ?? "",
            mobile: e["mobile"] ?? "",
            address: e["address"] ?? "",
          );
        }).toList();

    return customerDetails;
  }

  Future<bool> saveCustomerWithInvoice({
    required PrintInvoiceModel invoice,
  }) async {
    saveCustomerWithInvoiceLoading.value = true;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
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
          "updatedAt": DateTime.now().toIso8601String(),
          "invoices": FieldValue.arrayUnion([invoice.toJson()]),
        });

        return true;
      } else {
        await ref.set({
          "name": name.text,
          "address": address.text,
          "mobile": mobileNumber.text,
          "createdAt": DateTime.now().toIso8601String(),
          "invoices": [invoice.toJson()],
        });
        return true;
      }
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
  }
}
