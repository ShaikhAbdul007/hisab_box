import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/bank_details/model/bank_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';

import '../../../helper/helper.dart';

class BankdetailsController extends GetxController with CacheManager {
  final uid = SupabaseConfig.auth.currentUser?.id;

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

    try {
      if (uid == null) return;

      final response =
          await SupabaseConfig.from(
            'bank_details',
          ).select().eq('user_id', uid!).maybeSingle();

      if (response != null) {
        final details = BankModel.formJson({
          'upiId': response['upi_id'],
          'bankName': response['bank_name'],
          'accountHolder': response['account_holder'],
        });

        bankNameController.text = details.bankName ?? "";
        accountHolderNameController.text = details.accountName ?? '';
        upiIdController.text = details.upiId ?? '';

        saveBankModelData(details);
      }
    } catch (e) {
      showMessage(message: e.toString());
    } finally {
      setBankDetailsUpi.value = false;
    }
  }

  // ================================
  // INSERT / UPDATE (UPSERT)
  // ================================
  Future<void> saveBankDetails() async {
    bankDetailsUpi.value = true;

    final date = setFormateDate();
    final time = setFormateDate('hh:mm a');

    try {
      if (uid == null) throw "User not logged in";

      await SupabaseConfig.from('bank_details').upsert({
        'user_id': uid,
        'upi_id': upiIdController.text.trim(),
        'account_holder': accountHolderNameController.text.trim(),
        'bank_name': bankNameController.text.trim(),
        'created_at': '$date $time',
        'updated_at': '$date $time',
      });

      await getBankDetails();
      showMessage(message: 'Bank Details Save Successfully');
    } catch (e) {
      showMessage(message: e.toString());
    } finally {
      bankDetailsUpi.value = false;
    }
  }
}

// class BankdetailsController extends GetxController with CacheManager {
//   final uid = FirebaseAuth.instance.currentUser?.uid;
//   TextEditingController upiIdController = TextEditingController();
//   TextEditingController bankNameController = TextEditingController();
//   TextEditingController accountHolderNameController = TextEditingController();
//   RxBool bankDetailsUpi = false.obs;
//   RxBool setBankDetailsUpi = false.obs;

//   @override
//   void onInit() {
//     getSaveBankDetails();
//     super.onInit();
//   }

//   bool isValidUpi(String upi) {
//     final reg = RegExp(r'^[\w\.\-\_]{2,}@[A-Za-z]{2,}$');
//     return reg.hasMatch(upi.trim());
//   }

//   void getSaveBankDetails() async {
//     BankModel bankdata = retrieveBankModelDetail();
//     if (bankdata.upiId == null) {
//       customMessageOrErrorPrint(message: "isBlank: false");
//       await getBankDetails();
//     } else {
//       bankNameController.text = bankdata.bankName ?? "";
//       accountHolderNameController.text = bankdata.accountName ?? '';
//       upiIdController.text = bankdata.upiId ?? '';
//       customMessageOrErrorPrint(message: "isBlank: true");
//     }
//   }

//   Future<void> getBankDetails() async {
//     setBankDetailsUpi.value = true;
//     try {
//       final ref = FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .collection('bankDetails')
//           .doc('details');
//       final doc = await ref.get();
//       if (doc.exists) {
//         BankModel details = BankModel.formJson(doc.data()!);
//         bankNameController.text = details.bankName ?? "";
//         accountHolderNameController.text = details.accountName ?? '';
//         upiIdController.text = details.upiId ?? '';
//         saveBankModelData(details);
//         customMessageOrErrorPrint(message: "Bank Details: $details");
//       }
//     } on FirebaseAuthException catch (e) {
//       showMessage(message: e.message ?? '');
//     } catch (e) {
//       customMessageOrErrorPrint(message: "Fetch customers error: $e");
//       showMessage(message: '$e');
//       return;
//     } finally {
//       setBankDetailsUpi.value = false;
//     }
//   }

//   Future<void> saveBankDetails() async {
//     bankDetailsUpi.value = true;
//     String date = setFormateDate();
//     String time = setFormateDate('hh:mm a');
//     customMessageOrErrorPrint(message: "Fetch customers error: $date");
//     customMessageOrErrorPrint(message: "Fetch customers error: $time");

//     try {
//       final uid = FirebaseAuth.instance.currentUser?.uid;
//       if (uid == null) throw "User not logged in";

//       final bankRef = FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .collection('bankDetails')
//           .doc('details');

//       await bankRef.set({
//         'upiId': upiIdController.text.trim(),
//         'accountHolder': accountHolderNameController.text.trim(),
//         'bankName': bankNameController.text.trim(),
//         'createdAt': '$date$time',
//         'updatedAt': '$date$time',
//       }, SetOptions(merge: true));
//       getBankDetails();
//       showMessage(message: 'Bank Details Save Successfully');
//     } catch (e) {
//       showMessage(message: e.toString());
//     } finally {
//       bankDetailsUpi.value = false;
//     }
//   }
// }
