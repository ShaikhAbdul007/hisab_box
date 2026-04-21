import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/add_user/model/employee_model.dart';
import 'package:inventory/module/add_user/repo/add_user_repo.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';

class AllUserDetailController extends GetxController {
  AddUserRepo addUserRepo = AddUserRepo();
  RxBool isLoading = false.obs;
  RxBool isEditingEnable = false.obs;
  RxBool isUpdateEmployeeLoading = false.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileController = TextEditingController();
  final roleController = TextEditingController();
  EmpolyeeData data = Get.arguments;

  RxMap<String, RxBool> permissions =
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
    super.onInit();
    setData();
  }

  void setData() {
    final permissionData = data.permissions;
    nameController.text = data.name ?? '';
    emailController.text = data.email ?? '';
    mobileController.text = data.mobileNo ?? '';
    roleController.text = data.role?.name ?? '';
    permissions['p_customer_list']?.value =
        permissionData?.pCustomerList ?? false;
    permissions['p_credit_list']?.value = permissionData?.pCreditList ?? false;
    permissions['p_reconcile_credit']?.value =
        permissionData?.pReconcileCredit ?? false;
    permissions['p_add_user']?.value = permissionData?.pAddUser ?? false;
    permissions['p_add_bank_details']?.value =
        permissionData?.pAddBankDetails ?? false;
    permissions['p_see_revenue']?.value = permissionData?.pSeeRevenue ?? false;
    permissions['p_see_received_cash']?.value =
        permissionData?.pSeeReceivedCash ?? false;
    permissions['p_see_received_credit']?.value =
        permissionData?.pSeeReceivedCredit ?? false;
    permissions['p_see_received_card']?.value =
        permissionData?.pSeeReceivedCard ?? false;
    permissions['p_see_received_upi']?.value =
        permissionData?.pSeeReceivedUpi ?? false;
    permissions['p_see_report']?.value = permissionData?.pSeeReport ?? false;
    permissions['p_see_today_sale']?.value =
        permissionData?.pSeeTodaySale ?? false;
    permissions['p_see_today_sale_detail']?.value =
        permissionData?.pSeeTodaySaleDetail ?? false;
    permissions['p_add_product']?.value = permissionData?.pAddProduct ?? false;
    permissions['p_add_manual_product']?.value =
        permissionData?.pAddManualProduct ?? false;
    permissions['p_delete_product']?.value =
        permissionData?.pDeleteProduct ?? false;
    permissions['p_add_loose_product']?.value =
        permissionData?.pAddLooseProduct ?? false;
    permissions['p_transfer_godown_to_shop']?.value =
        permissionData?.pTransferGodownToShop ?? false;
    permissions['p_edit_profile']?.value =
        permissionData?.pEditProfile ?? false;
    permissions['p_edit_product_details']?.value =
        permissionData?.pEditProductDetails ?? false;
    permissions['p_edit_loose_product_details']?.value =
        permissionData?.pEditLooseProductDetails ?? false;
    permissions['p_edit_godown_product_details']?.value =
        permissionData?.pEditGodownProductDetails ?? false;
  }

  Future<void> updateEmployeePermission({
    required dynamic body,
    required String employeeId,
  }) async {
    isUpdateEmployeeLoading.value = true;
    try {
      final response = await addUserRepo.updateEmployees(
        body: body,
        employeeId: employeeId,
      );
      if (response.success == success) {
        showSnackBar(error: response.msg!, isError: false);
        Get.back();
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info((e).toString());
      showSnackBar(error: SupabaseErrorHandler.getMessage(e));
    } finally {
      isUpdateEmployeeLoading.value = false;
    }
  }
}
