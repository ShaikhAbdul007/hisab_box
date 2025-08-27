import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/helper.dart';
import '../../../helper/app_message.dart';
import '../../../helper/set_format_date.dart';
import '../model/expens_model.dart';

class ExpenseController extends GetxController {
  TextEditingController amount = TextEditingController();
  TextEditingController expensionName = TextEditingController();
  TextEditingController notes = TextEditingController();
  final _auth = FirebaseAuth.instance;
  RxBool isExpenseLoading = false.obs;
  RxBool isExpenseSaveLoading = false.obs;
  RxList<ExpenseModel> expenseList = <ExpenseModel>[].obs;

  @override
  void onInit() {
    getAllExpenses();
    super.onInit();
  }

  Future<void> saveExpense(ExpenseModel expense) async {
    isExpenseSaveLoading.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .add(expense.toMap());
      showMessage(message: expenseSaveSuccessMessage);
      Get.back();
      clear();
      getAllExpenses();
    } on FirebaseException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isExpenseSaveLoading.value = false;
    }
  }

  Future<void> getAllExpenses() async {
    isExpenseLoading.value = true;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final todayDate = setFormateDate();
    if (uid == null) {
      return;
    }
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('expenses')
              .where('soldAt', isEqualTo: todayDate)
              .get();

      expenseList.value =
          snapshot.docs.map((doc) {
            return ExpenseModel.fromMap(doc.data());
          }).toList();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isExpenseLoading.value = false;
    }
  }

  void clear() {
    amount.clear();
    expensionName.clear();
    notes.clear();
  }
}
