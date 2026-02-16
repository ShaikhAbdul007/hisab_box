import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
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
    fetchCreditCustomers();
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
  Future<void> fetchCreditCustomers() async {
    try {
      customDataLoading.value = true;

      // 1️⃣ SUPABASE QUERY
      // Hum customers uthayenge aur unke sales aur un sales ke payments join karenge
      final response = await SupabaseConfig.from('customers')
          .select('''
          id, 
          name, 
          mobile_number, 
          address,
          sales (
            id,
            total_amount,
            created_at,
            sale_payments (
              credit_amount,
              created_at
            )
          )
        ''')
          .eq('user_id', uid);

      final List data = response as List;
      List<CustomerDetails> creditList = [];

      // 2️⃣ MAPPING & CALCULATING CREDIT
      for (var customer in data) {
        double totalPendingCredit = 0;
        List<dynamic> sales = customer['sales'] ?? [];

        for (var sale in sales) {
          List<dynamic> payments = sale['sale_payments'] ?? [];
          for (var payment in payments) {
            double credit = (payment['credit_amount'] ?? 0).toDouble();
            if (credit > 0) {
              totalPendingCredit += credit;
            }
          }
        }
        // Agar customer par udhaari hai, toh hi list mein add karo
        if (totalPendingCredit > 0) {
          creditList.add(
            CustomerDetails(
              id: customer['id'],
              name: customer['name'],
              //  mobileNumber: customer['mobile_number'],
              address: customer['address'],
              totalCredit:
                  totalPendingCredit, // Ye field aapke model mein honi chahiye
              //  lastTransactionDate: lastCreditDate,
            ),
          );
        }
      }

      // 3️⃣ SORTING (Sabse zyada udhaari wala upar)
      creditList.sort((a, b) => b.totalCredit.compareTo(a.totalCredit));

      customerDetailList.value = creditList;
    } catch (e) {
      print("🚨 Fetch Credit Customers Error: $e");
      customerDetailList.clear();
    } finally {
      customDataLoading.value = false;
    }
  }
}
