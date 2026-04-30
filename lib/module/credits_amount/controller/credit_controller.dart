import 'package:inventory/helper/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/order_complete/model/customer_details_model.dart'; // 🔥 GlobalStore Connection

class CredtiController extends GetxController with CacheManager {
  // 🔥 GlobalStore Reference

  RxBool customDataLoading = false.obs;
  RxString searchText = ''.obs;
  RxList<CustomerDetails> customerDetailList = <CustomerDetails>[].obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    fetchCreditReports();

    // 🔥 Live Sync: Agar koi naya credit bill kat-ta hai, toh list khud update ho jayegi
    // ever(globalStore.allSalesList, (_) => fetchCreditReports());

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
    } catch (e) {
      AppLogger.error('Credit report build failed', e, 'CredtiController');
      showSnackBar(error: e.toString());
    } finally {
      customDataLoading.value = false;
    }
  }
}
