import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/order_complete/controller/order_controller.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import '../../order_complete/model/customer_details_model.dart';

class CustomerController extends GetxController with CacheManager {
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

    // 🔥 1️⃣ LOAD FROM CACHE FIRST (No change here)
    final cacheCustomers = await retrieveCustomerList();
    if (cacheCustomers.isNotEmpty) {
      customerDetailList.value = cacheCustomers;
    }

    // 🔥 2️⃣ FETCH FROM SUPABASE (SYNC)
    // Note: Assuming you have a way to get the current user's ID

    final userId = resolveUserId(customDataLoading.value);
    if (userId == null) {
      customDataLoading.value = false;
      return;
    }

    try {
      // Firebase collection ki jagah Supabase table use kar rahe hain
      final List<dynamic> response = await SupabaseConfig.from('customers')
          .select()
          .eq('user_id', userId)
          .order(
            'name',
            ascending: true,
          ); // Customers ko alphabetic order mein mangwa rahe hain

      final customers =
          response.map((data) => CustomerDetails.fromJson(data)).toList();

      // 🔥 UPDATE UI + CACHE
      customerDetailList.value = customers;
      saveCustomerList(customers);

      AppLogger.info(
        ("✅ Successfully fetched ${customers.length} customers from Supabase")
            .toString(),
      );
    } catch (e) {
      // Variable names kept exactly same as requested
      AppLogger.error("Fetch customers error", e, "CustomerController");
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      customDataLoading.value = false;
    }
  }
}
