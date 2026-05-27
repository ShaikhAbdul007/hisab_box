import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/credits_amount/model/credit_model.dart';
import 'package:inventory/module/credits_amount/repo/credit_repo.dart';

class CredtiController extends GetxController with CacheManager {
  // 🔥 GlobalStore Reference

  CreditRepo creditRepo = CreditRepo();
  RxBool customDataLoading = false.obs;
  RxString searchText = ''.obs;
  RxList<CreditDataItem> customerDetailList = <CreditDataItem>[].obs;
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
  double calculateTotalCredit(CreditDataItem customer) {
    return customer.remainingAmount != null
        ? double.tryParse(customer.remainingAmount!) ?? 0.0
        : 0.0;
  }

  // ===================================================
  // 🔥 OPTIMIZED: Ab ye RAM (GlobalStore) se data leta hai
  // ===================================================
  Future<void> fetchCreditReports() async {
    try {
      customDataLoading.value = true;
      final response = await creditRepo.fetchCreditAmountData();
      if (response.success == success) {
        customerDetailList.value = response.data?.data ?? [];
      } else if (response.success == failed) {
        showSnackBar(error: response.message ?? "Update Failed!");
      } else {
        showSnackBar(error: response.message ?? "Update Failed!");
      }
    } catch (e) {
      AppLogger.error('Credit report build failed', e, 'CredtiController');
      showSnackBar(error: e.toString());
    } finally {
      customDataLoading.value = false;
    }
  }
}
