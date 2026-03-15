import 'package:inventory/helper/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/bank_details/model/bank_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';

import '../../../helper/helper.dart';

class BankdetailsController extends GetxController with CacheManager {
  TextEditingController upiIdController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();

  RxBool bankDetailsUpi = false.obs;
  RxBool setBankDetailsUpi = false.obs;
  RxBool readOnly = false.obs;

  @override
  void onInit() {
    getSaveBankDetails();
    super.onInit();
  }

  bool isValidUpi(String upi) {
    final reg = RegExp(r'^[\w\.\-\_]{2,}@[A-Za-z]{2,}$');
    return reg.hasMatch(upi.trim());
  }

  // ================================
  // LOAD FROM CACHE → ELSE DB
  // ================================
  void getSaveBankDetails() async {
    BankModel bankdata = retrieveBankModelDetail();

    if (bankdata.upiId == null || bankdata.upiId!.isEmpty) {
      await getBankDetails();
    } else {
      bankNameController.text = bankdata.bankName ?? "";
      accountHolderNameController.text = bankdata.accountName ?? '';
      upiIdController.text = bankdata.upiId ?? '';
    }
  }

  // ================================
  // FETCH FROM SUPABASE
  // ================================
  Future<void> getBankDetails() async {
    setBankDetailsUpi.value = true;
    final userId = resolveUserId(setBankDetailsUpi.value);

    try {
      if (userId == null) return;
      final response =
          await SupabaseConfig.from(
            'bank_details',
          ).select().eq('user_id', userId).maybeSingle();

      if (response != null) {
        final details = BankModel.formJson({
          'upiId': response['upi_id'],
          'bankName': response['bank_name'],
          'accountHolder': response['account_holder'],
        });
        readOnly.value = true;
        bankNameController.text = details.bankName ?? "";
        accountHolderNameController.text = details.accountName ?? '';
        upiIdController.text = details.upiId ?? '';
        saveBankModelData(details);
      }
    } catch (e) {
      AppLogger.info((e).toString());
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      setBankDetailsUpi.value = false;
    }
  }

  // ================================
  // INSERT / UPDATE (UPSERT)
  // ================================
  Future<void> saveBankDetails() async {
    bankDetailsUpi.value = true;
    final userId = resolveUserId(bankDetailsUpi.value);
    try {
      if (userId == null) throw "User not logged in";
      final String timestamp = DateTime.now().toIso8601String();
      await SupabaseConfig.from('bank_details').upsert({
        'user_id': userId,
        'upi_id': upiIdController.text.trim(),
        'account_holder': accountHolderNameController.text.trim(),
        'bank_name': bankNameController.text.trim(),
        'updated_at': timestamp,
      }, onConflict: 'user_id');

      await getBankDetails();
      showMessage(message: 'Bank Details Saved Successfully');
      readOnly.value = false;
    } catch (e) {
      AppLogger.info(("🚨 Bank Save Error: $e").toString());
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      bankDetailsUpi.value = false;
    }
  }
}
