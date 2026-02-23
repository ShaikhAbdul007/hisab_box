import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/order_complete/model/customer_details_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';

class CredtiController extends GetxController with CacheManager {
  final uid = SupabaseConfig.auth.currentUser?.id ?? '';
  RxBool customDataLoading = false.obs;
  RxString searchText = ''.obs;
  RxList<CustomerDetails> customerDetailList = <CustomerDetails>[].obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    fetchCreditReports();
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
  Future<void> fetchCreditReports() async {
    try {
      customDataLoading.value = true;

      // 🎯 Filter 'sales' table ke 'user_id' par lagaya hai kyunki payment mein nahi hai
      final response = await SupabaseConfig.from('sale_payments')
          .select('''
          credit_amount,
          created_at,
          payment_mode,
          sales!inner (
            bill_no,
            user_id,
            customers (
              name,
              mobile_number
            )
          )
        ''')
          .gt('credit_amount', 0)
          .eq('sales.user_id', uid) // 🔥 YE CHANGE KIYA HAI
          .order('created_at', ascending: false);

      final List data = response as List;
      List<CustomerDetails> creditList = [];

      for (var item in data) {
        double amount =
            double.tryParse(item['credit_amount'].toString()) ?? 0.0;
        var saleObj = item['sales'];
        var customerObj = saleObj != null ? saleObj['customers'] : null;

        String displayName =
            (customerObj != null && customerObj['name'] != null)
                ? customerObj['name']
                : "Walk-in (Bill #${saleObj['bill_no']})";

        creditList.add(
          CustomerDetails(
            name: displayName,
            totalCredit: amount,
            address: formatDateTime(item['created_at'].toString()), // Kab diya
          ),
        );
      }

      customerDetailList.assignAll(creditList);
    } catch (e) {
      print("🚨 Detailed Credit Error: $e");
    } finally {
      customDataLoading.value = false;
    }
  }
}
