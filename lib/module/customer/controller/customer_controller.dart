import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/customer/model/all_customer_model.dart';
import 'package:inventory/module/customer/repo/customer_repo.dart';
import 'package:inventory/module/order_complete/controller/order_controller.dart';

import 'package:inventory/supabase_db/supabase_error_handler.dart';
import '../../order_complete/model/customer_details_model.dart';

class CustomerController extends GetxController with CacheManager {
  CustomerRepo customerRepo = CustomerRepo();
  var orderController = Get.put(OrderController());
  RxBool customDataLoading = false.obs;
  RxString searchText = ''.obs;
  RxList<CustomerDetails> customerDetailList = <CustomerDetails>[].obs;
  RxList<CustomerItem> customerList = <CustomerItem>[].obs;
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
    try {
      final response = await customerRepo.getAllCustomer();
      if (response.success == success) {
        customerList.value = response.data?.customers ?? [];
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info((e).toString());
      showSnackBar(error: SupabaseErrorHandler.getMessage(e));
    } finally {
      customDataLoading.value = false;
    }
  }
}
