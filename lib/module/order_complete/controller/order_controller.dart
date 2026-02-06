import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/order_complete/model/customer_details_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';

import '../../sell/model/print_model.dart';

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
  // 🔥 CACHE-FIRST CUSTOMER LOAD (SUPABASE)
  // ===============================
  Future<List<CustomerDetails>> loadAllCustomers() async {
    // 1️⃣ LOAD FROM CACHE
    final cacheList = await retrieveCustomerList();
    if (cacheList.isNotEmpty) {
      customerDetails.value = cacheList;
      return customerDetails;
    }

    // 2️⃣ FALLBACK TO SUPABASE
    if (uid == null) return [];

    try {
      final List<dynamic> response = await SupabaseConfig.from(
        'customers',
      ).select().eq('user_id', uid ?? '');

      final list =
          response.map((e) {
            return CustomerDetails(
              id: e["id"].toString(),
              name: e["name"] ?? "",
              mobile:
                  e["mobile_number"] ??
                  "", // As per your schema 'mobile_number'
              address: e["address"] ?? "",
              totalPaid:
                  (e["total_paid"] ?? 0)
                      .toDouble(), // Schema columns adjust kiye hain
              totalCredit: (e["total_credit"] ?? 0).toDouble(),
              createdAt: e["created_at"],
            );
          }).toList();

      customerDetails.value = list;

      // 3️⃣ SAVE TO CACHE
      saveCustomerList(list);
      return list;
    } catch (e) {
      print("Error loading customers: $e");
      return [];
    }
  }

  // ===============================
  // 🔥 SAVE + CACHE SYNC (SUPABASE)
  // ===============================
  Future<bool> saveCustomerWithInvoice({
    required PrintInvoiceModel invoice,
  }) async {
    saveCustomerWithInvoiceLoading.value = true;

    try {
      // 1️⃣ Check if customer exists by mobile_number
      final customerResponse =
          await SupabaseConfig.from('customers')
              .select('id')
              .eq('mobile_number', mobileNumber.text)
              .eq('user_id', uid ?? '')
              .maybeSingle();

      String? customerId;

      if (customerResponse != null) {
        customerId = customerResponse['id'].toString();
        // Update Existing
        await SupabaseConfig.from('customers')
            .update({
              "name": name.text,
              "address": address.text,
              "description": description.text,
            })
            .eq('id', customerId);
      } else {
        // Insert New Customer (Table columns: mobile_number, user_id, description, address, name)
        final newCustomer =
            await SupabaseConfig.from('customers')
                .insert({
                  "user_id": uid,
                  "name": name.text,
                  "address": address.text,
                  "mobile_number": mobileNumber.text,
                  "description": description.text,
                  "created_at": DateTime.now().toIso8601String(),
                })
                .select('id')
                .single();

        customerId = newCustomer['id'].toString();
      }

      // 2️⃣ SALE TABLE UPDATE (Optional but Recommended)
      // Agar tune sale pehle hi create kar di hai, toh usme customer_id update kar do
      // Isse 'sales' aur 'customers' table link ho jayengi
      /*
    if (invoice.billNo != null) {
       await SupabaseConfig.from('sales')
          .update({'customer_id': customerId})
          .eq('id', invoice.billNo!.replaceAll('HB-', ''));
    }
    */

      await loadAllCustomers();
      return true;
    } catch (e) {
      print("🚨 Save Error: $e");
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
