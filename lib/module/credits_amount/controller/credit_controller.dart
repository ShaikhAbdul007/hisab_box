import 'package:inventory/helper/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/order_complete/model/customer_details_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import 'package:inventory/module/gobal_module/gobal_controller.dart'; // 🔥 GlobalStore Connection

class CredtiController extends GetxController with CacheManager {
  final uid = SupabaseConfig.auth.currentUser?.id ?? '';
  final globalStore = Get.find<GlobalStore>(); // 🔥 GlobalStore Reference

  RxBool customDataLoading = false.obs;
  RxString searchText = ''.obs;
  RxList<CustomerDetails> customerDetailList = <CustomerDetails>[].obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    fetchCreditReports();

    // 🔥 Live Sync: Agar koi naya credit bill kat-ta hai, toh list khud update ho jayegi
    ever(globalStore.allSalesList, (_) => fetchCreditReports());

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
  // 🔥 OPTIMIZED: Ab ye RAM (GlobalStore) se data leta hai
  // ===================================================
  Future<void> fetchCreditReports() async {
    try {
      customDataLoading.value = true;

      // Loader ke liye thoda delay agar list khali hai (UX ke liye)
      if (globalStore.allSalesList.isEmpty) {
        // Agar global store khali hai toh fetch mat karo, wait karo sync ka
        customDataLoading.value = false;
        return;
      }

      // 1️⃣ STEP 1: GlobalStore ki sales list se sirf wo bills nikalo jisme credit hai
      List<CustomerDetails> creditList = [];

      for (var sale in globalStore.allSalesList) {
        // Payment model se credit amount check karo
        double creditAmt = sale.payment?.credit ?? 0.0;

        if (creditAmt > 0) {
          // Customer ka naam nikalo, agar nahi hai toh bill number dikhao
          String displayName =
              (sale.customerName != null && sale.customerName!.isNotEmpty)
                  ? sale.customerName!
                  : "Walk-in (Bill #${sale.billNo})";

          creditList.add(
            CustomerDetails(
              name: displayName,
              totalCredit: creditAmt,
              address: "${sale.soldAt} ${sale.time}", // Date aur Time sync
            ),
          );
        }
      }

      // 2️⃣ STEP 2: UI update karo
      customerDetailList.assignAll(creditList);
    } catch (e) {
      AppLogger.error('Credit report build failed', e, 'CredtiController');
    showSnackBar(error: e.toString());
    } finally {
      customDataLoading.value = false;
    }
  }
}
