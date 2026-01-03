import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/bank_details/model/bank_model.dart';

import '../../../helper/helper.dart';

class BankdetailsController extends GetxController with CacheManager {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  TextEditingController upiIdController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();
  RxBool bankDetailsUpi = false.obs;
  RxBool setBankDetailsUpi = false.obs;

  @override
  void onInit() {
    getSaveBankDetails();
    super.onInit();
  }

  bool isValidUpi(String upi) {
    final reg = RegExp(r'^[\w\.\-\_]{2,}@[A-Za-z]{2,}$');
    return reg.hasMatch(upi.trim());
  }

  void getSaveBankDetails() async {
    BankModel bankdata = retrieveBankModelDetail();
    if (bankdata.upiId == null) {
      customMessageOrErrorPrint(message: "isBlank: false");
      await getBankDetails();
    } else {
      bankNameController.text = bankdata.bankName ?? "";
      accountHolderNameController.text = bankdata.accountName ?? '';
      upiIdController.text = bankdata.upiId ?? '';
      customMessageOrErrorPrint(message: "isBlank: true");
    }
  }

  Future<void> getBankDetails() async {
    setBankDetailsUpi.value = true;
    try {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('bankDetails')
          .doc('details');
      final doc = await ref.get();
      if (doc.exists) {
        BankModel details = BankModel.formJson(doc.data()!);
        bankNameController.text = details.bankName ?? "";
        accountHolderNameController.text = details.accountName ?? '';
        upiIdController.text = details.upiId ?? '';
        saveBankModelData(details);
        customMessageOrErrorPrint(message: "Bank Details: $details");
      }
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.message ?? '');
    } catch (e) {
      customMessageOrErrorPrint(message: "Fetch customers error: $e");
      showMessage(message: '$e');
      return;
    } finally {
      setBankDetailsUpi.value = false;
    }
  }

  Future<void> saveBankDetails() async {
    bankDetailsUpi.value = true;
    String date = setFormateDate();
    String time = setFormateDate('HH:mm');
    customMessageOrErrorPrint(message: "Fetch customers error: $date");
    customMessageOrErrorPrint(message: "Fetch customers error: $time");

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw "User not logged in";

      final bankRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('bankDetails')
          .doc('details');

      await bankRef.set({
        'upiId': upiIdController.text.trim(),
        'accountHolder': accountHolderNameController.text.trim(),
        'bankName': bankNameController.text.trim(),
        'createdAt': '$date$time',
        'updatedAt': '$date$time',
      }, SetOptions(merge: true));
      getBankDetails();
      showMessage(message: 'Bank Details Save Successfully');
    } catch (e) {
      showMessage(message: e.toString());
    } finally {
      bankDetailsUpi.value = false;
    }
  }
}
