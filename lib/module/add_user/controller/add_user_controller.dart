import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/add_user/model/all_user_role_model.dart';
import 'package:inventory/module/add_user/repo/add_user_repo.dart';
import 'package:inventory/module/add_user/repo/user_role_repo.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';

class AddUserController extends GetxController with CacheManager {
  UserRoleRepo userRoleRepo = UserRoleRepo();
  AddUserRepo addUserRepo = AddUserRepo();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileController = TextEditingController();
  RxInt currentExpandedIndex = (-1).obs;
  RxBool isLoading = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool isFetchUserRole = false.obs;
  RxString selectedRole = ''.obs;
  RxList<AllUserRoleData> userRoleList = <AllUserRoleData>[].obs;

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

  @override
  void onInit() {
    getUserRoleData();
    super.onInit();
  }

  void getUserRoleData() async {
    await fetchUserRole();
  }

  Future<void> createStaffAccount() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackBar(error: "Email and Password are required");
      return;
    }
  }

  Future<void> fetchUserRole() async {
    isFetchUserRole.value = true;
    try {
      var response = await userRoleRepo.getAllUserRole();
      if (response.success == success) {
        userRoleList.value = response.data ?? [];
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isFetchUserRole.value = false;
    }
  }

  Future<void> addUserRole({required dynamic body}) async {
    isSaveLoading.value = true;
    try {
      var response = await addUserRepo.addEmployees(body: body);
      if (response.success == success) {
        Get.back(result: true);
        showSnackBar(error: response.msg ?? "Role added successfully", isError: false);
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }
}
