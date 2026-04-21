import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';

class AddUserController extends GetxController with CacheManager {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileController = TextEditingController();
  RxInt currentExpandedIndex = (-1).obs;
  RxBool isLoading = false.obs;
  RxString selectedRole = 'staff'.obs;

  // 🔥 Permissions Map: Sab default false
  var permissions =
      <String, RxBool>{
        'p_customer_list': false.obs,
        'p_credit_list': false.obs,
        'p_reconcile_credit': false.obs,
        'p_add_user': false.obs,
        'p_add_bank_details': false.obs,
        'p_see_revenue': false.obs,
        'p_see_received_cash': false.obs,
        'p_see_received_credit': false.obs,
        'p_see_received_card': false.obs,
        'p_see_received_upi': false.obs,
        'p_see_report': false.obs,
        'p_see_today_sale': false.obs,
        'p_see_today_sale_detail': false.obs,
        'p_add_product': false.obs,
        'p_add_manual_product': false.obs,
        'p_delete_product': false.obs,
        'p_add_loose_product': false.obs,
        'p_transfer_godown_to_shop': false.obs,
        'p_edit_profile': false.obs,
        'p_edit_product_details': false.obs,
        'p_edit_loose_product_details': false.obs,
        'p_edit_godown_product_details': false.obs,
      }.obs;

  Future<void> createStaffAccount() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackBar(error: "Email and Password are required");
      return;
    }
  }
}
