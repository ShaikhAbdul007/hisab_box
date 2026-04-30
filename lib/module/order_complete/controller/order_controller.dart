import 'package:inventory/helper/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/customer/model/all_customer_model.dart';
import 'package:inventory/module/order_complete/model/customer_details_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';

import '../../sell/model/print_model.dart';

class OrderController extends GetxController with CacheManager {
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController description = TextEditingController();
  RxList<CustomerItem> customerDetails = <CustomerItem>[].obs;
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

  Future<List<CustomerDetails>> loadAllCustomers() async {
    try {
      return [];
    } catch (e) {
      AppLogger.info(("Error loading customers: $e").toString());
      showSnackBar(error: e.toString());
      return [];
    }
  }

  // ===============================
  // 🔥 SAVE + CACHE SYNC (SUPABASE)
  // ===============================
  Future<bool> saveCustomerWithInvoice({
    required PrintInvoiceModel invoice,
  }) async {
    final String? currentUid = resolveUserId(
      saveCustomerWithInvoiceLoading.value,
    );
    if (currentUid == null) return false;

    saveCustomerWithInvoiceLoading.value = true;

    try {
      // String cMobile = mobileNumber.text.trim();
      // if (cMobile.isEmpty) return false;

      // // 1. Customer Search/Create
      // final customerResponse =
      //     await SupabaseConfig.from('customers')
      //         .select('id')
      //         .eq('mobile_number', cMobile)
      //         .eq('user_id', currentUid)
      //         .maybeSingle();

      // dynamic customerId;

      // if (customerResponse != null) {
      //   customerId = customerResponse['id'];
      //   await SupabaseConfig.from('customers')
      //       .update({
      //         "name": name.text.trim(),
      //         "address": address.text.trim(),
      //         "description": description.text.trim(),
      //       })
      //       .eq('id', customerId);
      // } else {
      //   final newCustomer =
      //       await SupabaseConfig.from('customers')
      //           .insert({
      //             "user_id": currentUid,
      //             "name": name.text.trim(),
      //             "address": address.text.trim(),
      //             "mobile_number": cMobile,
      //             "description": description.text.trim(),
      //           })
      //           .select('id')
      //           .single();
      //   customerId = newCustomer['id'];
      // }

      // // 2. 🎯 TARGET FIX: Sales Update
      // // Hum bill_no ko int mein convert kar rahe hain aur user_id ka check laga rahe hain
      // final int numericBillNo = int.tryParse(invoice.billNo.toString()) ?? 0;

      // final updateRes =
      //     await SupabaseConfig.from('sales')
      //         .update({'customer_id': customerId})
      //         .eq(
      //           'bill_no',
      //           numericBillNo,
      //         ) // 🔥 String ki jagah Int bhej rahe hain
      //         .eq(
      //           'user_id',
      //           currentUid,
      //         ) // 🔥 Security: Sirf apni hi dukan ka bill update ho
      //         .select();

      // if (updateRes.isEmpty) {
      //   AppLogger.info(("⚠️ Warning: Sales table mein Bill No $numericBillNo nahi mila!").toString());
      // } else {
      //   AppLogger.info(("✅ Success: Customer linked to Bill No $numericBillNo").toString());
      // }

      // await loadAllCustomers();
      return true;
    } catch (e) {
      AppLogger.info(("🚨 Save Customer Error Details: $e").toString());
      showSnackBar(error: e.toString());
      return false;
    } finally {
      saveCustomerWithInvoiceLoading.value = false;
    }
  }

  void setDataAsPerOptionSelected(CustomerItem option) {
    address.text = option.address ?? '';
    name.text = option.name ?? '';
    mobileNumber.text = option.mobileNo ?? '';
  }

  void clear() {
    name.clear();
    address.clear();
    mobileNumber.clear();
    description.clear();
  }
}
