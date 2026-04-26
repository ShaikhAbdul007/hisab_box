import 'package:inventory/helper/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/bank_details/model/bank_model.dart';
import 'package:inventory/module/bank_details/repo/bank_repo.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';

import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';

class BankDetailsController extends GetxController with CacheManager {
  BankRepo bankDetailsRepo = BankRepo();
  TextEditingController upiIdController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();

  RxBool bankDetailsUpi = false.obs;
  RxBool setBankDetailsUpi = false.obs;
  RxBool readOnly = false.obs;

  @override
  void onInit() {
    getCacheHasData();
    super.onInit();
  }

  bool isValidUpi(String upi) {
    final reg = RegExp(r'^[\w\.\-\_]{2,}@[A-Za-z]{2,}$');
    return reg.hasMatch(upi.trim());
  }

  void getCacheHasData() {
    final bankData = retrieveBankModelDetail();
    if (bankData.data?.bankName != null) {
      bankNameController.text = bankData.data?.bankName ?? "";
      accountHolderNameController.text = bankData.data?.accountHolder ?? '';
      upiIdController.text = bankData.data?.upiId ?? '';
      readOnly.value = true;
    } else {
      getBankDetails();
    }
  }

  Future<void> getBankDetails() async {
    setBankDetailsUpi.value = true;
    try {
      final response = await bankDetailsRepo.getBankDetails();
      if (response.success == success) {
        bankNameController.text = response.data?.bankName ?? "";
        accountHolderNameController.text = response.data?.accountHolder ?? '';
        upiIdController.text = response.data?.upiId ?? '';
        saveBankModelData(response);
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info((e).toString());
      showSnackBar(error: e.toString());
    } finally {
      setBankDetailsUpi.value = false;
    }
  }

  // ================================
  // INSERT / UPDATE (UPSERT)
  // ================================
  Future<void> saveBankDetails() async {
    bankDetailsUpi.value = true;
    var body = {
      "upi_id": "shop5@upi",
      "bank_name": "State Bank of India",
      "account_holder": "Shop Owner",
    };
    try {
      final response = await bankDetailsRepo.createBankDetails(body: body);
      if (response.success == success) {
        setBankData(response);
        saveBankModelData(response);
        getCacheHasData();
        showSnackBar(error: response.msg!, isError: false);
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info(("🚨 Bank Save Error: $e").toString());
      showSnackBar(error: e.toString());
    } finally {
      bankDetailsUpi.value = false;
    }
  }

  void setBankData(BankDetailsModel response) {
    bankNameController.text = response.data?.bankName ?? "";
    accountHolderNameController.text = response.data?.accountHolder ?? '';
    upiIdController.text = response.data?.upiId ?? '';
  }
}
