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
    // 1. Check Internet & UID
    final String? currentUid = uid;
    if (currentUid == null) {
      print("🚨 Error: No Authorized User Found");
      return false;
    }

    saveCustomerWithInvoiceLoading.value = true;

    try {
      // 2. Data Clean-up (Preventing empty strings in non-required fields)
      String cName = name.text.trim();
      String cMobile = mobileNumber.text.trim();
      String cAddress = address.text.trim();
      String cDesc = description.text.trim();

      if (cMobile.isEmpty) {
        print("🚨 Error: Mobile number is required");
        return false;
      }

      // 3. Customer Search (Checking existing)
      final customerResponse =
          await SupabaseConfig.from('customers')
              .select('id')
              .eq('mobile_number', cMobile)
              .eq('user_id', currentUid)
              .maybeSingle();

      String? customerId;

      if (customerResponse != null) {
        customerId = customerResponse['id'].toString();
        // Update Existing Customer
        await SupabaseConfig.from('customers')
            .update({"name": cName, "address": cAddress, "description": cDesc})
            .eq('id', customerId);
      } else {
        // Insert New Customer
        final newCustomer =
            await SupabaseConfig.from('customers')
                .insert({
                  "user_id": currentUid,
                  "name": cName,
                  "address": cAddress,
                  "mobile_number": cMobile,
                  "description": cDesc,
                })
                .select('id')
                .single();

        customerId = newCustomer['id'].toString();
      }

      // 4. Update Sales Table (Customer link karna)
      // Invoice Bill No ko parse karke Sales ID nikalna
      if (invoice.billNo != null) {
        String cleanBillId = invoice.billNo!.replaceAll('HB-', '').trim();

        // Ensure cleanBillId is a valid UUID before updating
        if (cleanBillId.length >= 32) {
          await SupabaseConfig.from(
            'sales',
          ).update({'customer_id': customerId}).eq('id', cleanBillId);
          print("✅ Sale linked to customer");
        }
      }

      await loadAllCustomers();
      return true;
    } catch (e) {
      print("🚨 Save Customer Error: $e");
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
