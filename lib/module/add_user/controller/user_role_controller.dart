import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Mixin
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/add_user/model/all_user_role_model.dart';
import 'package:inventory/module/add_user/repo/user_role_repo.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import '../../../helper/app_message.dart';

class UserRoleController extends GetxController with CacheManager {
  UserRoleRepo userRoleRepo = UserRoleRepo();
  TextEditingController role = TextEditingController();
  RxBool isSaveLoading = false.obs;
  RxBool isDeleteUserRole = false.obs;
  RxBool isFetchUserRole = false.obs;
  RxList<AllUserRoleData> userRoleList = <AllUserRoleData>[].obs;

  @override
  void onInit() {
    getUserRoleData();
    super.onInit();
  }

  void getUserRoleData() async {
    await fetchUserRole();
  }

  Future<void> addUserRole(String categoryName) async {
    isSaveLoading.value = true;

    try {
      var body = {"name": categoryName, "level": 1};
      final response = await userRoleRepo.createUserRole(body: body);
      if (response.success == success) {
        Get.back();
        clear();
        await fetchUserRole();
        showSnackBar(error: response.msg!, isError: false);
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }
    } catch (e) {
      clear();
      Get.back();
      showSnackBar(error: e.toString());
    } finally {
      isSaveLoading.value = false;
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

  Future<void> deleteUserRole(String userRoleId) async {
    isDeleteUserRole.value = true;

    try {
      var response = await userRoleRepo.deleteUserRole(id: userRoleId);
      if (response.success == success) {
        showSnackBar(error: response.msg!, isError: false);
        await fetchUserRole();
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isDeleteUserRole.value = false;
    }
  }

  void clear() {
    role.clear();
  }
}
