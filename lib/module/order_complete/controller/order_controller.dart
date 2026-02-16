import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/order_complete/model/customer_details_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';

import '../../sell/model/print_model.dart';

class OrderController extends GetxController with CacheManager {
  final String? uid = SupabaseConfig.auth.currentUser?.id;
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController description = TextEditingController();
  RxList<CustomerDetails> customerDetails = <CustomerDetails>[].obs;
  RxBool saveCustomerWithInvoiceLoading = false.obs;
  RxBool homeButtonVisible = true.obs;

  late PrintInvoiceModel data;

  @override
  void onInit() {
    if (Get.arguments != null) {
      data = Get.arguments as PrintInvoiceModel;
      setButtonValue();
    }
    loadAllCustomers();
    super.onInit();
  }

  void setButtonValue() {
    // 3. Ab ye error nahi dega kyunki 'data' ab Model ban chuka hai
    if (data.payment != null && (data.payment!.credit > 0)) {
      homeButtonVisible.value = false;
    } else {
      homeButtonVisible.value = true;
    }
  }

  // ===============================
  // 🔥 CACHE-FIRST CUSTOMER LOAD (SUPABASE)
  // ===============================
  Future<List<CustomerDetails>> loadAllCustomers() async {
    // 1️⃣ LOAD FROM CACHE

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
    final String? currentUid = uid;
    if (currentUid == null) return false;

    saveCustomerWithInvoiceLoading.value = true;

    try {
      String cMobile = mobileNumber.text.trim();
      if (cMobile.isEmpty) return false;

      // 1. Customer Search
      final customerResponse =
          await SupabaseConfig.from('customers')
              .select('id')
              .eq('mobile_number', cMobile)
              .eq('user_id', currentUid)
              .maybeSingle();

      dynamic customerId; // dynamic rakho taaki type ka locha na ho

      if (customerResponse != null) {
        customerId = customerResponse['id'];
        await SupabaseConfig.from('customers')
            .update({
              "name": name.text.trim(),
              "address": address.text.trim(),
              "description": description.text.trim(),
            })
            .eq('id', customerId);
      } else {
        final newCustomer =
            await SupabaseConfig.from('customers')
                .insert({
                  "user_id": currentUid,
                  "name": name.text.trim(),
                  "address": address.text.trim(),
                  "mobile_number": cMobile,
                  "description": description.text.trim(),
                })
                .select('id')
                .single();
        customerId = newCustomer['id'];
      }

      // 2. 🎯 TARGET FIX: Sales Update

      await SupabaseConfig.from('sales')
          .update({'customer_id': customerId})
          .eq(
            'bill_no',
            invoice.billNo.toString(),
          ); // 🚩 Yahan error aa raha hai agar saleId UUID nahi hai

      await loadAllCustomers();
      return true;
    } catch (e) {
      print("🚨 Save Customer Error Details: $e");
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
