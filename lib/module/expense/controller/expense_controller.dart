import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/expense/model/all_expense_model.dart';
import 'package:inventory/module/expense/repo/expense_repo.dart';
import '../model/expens_model.dart';

class ExpenseController extends GetxController {
  ExpenseRepo expenseRepo = ExpenseRepo();
  TextEditingController amount = TextEditingController();
  TextEditingController expensionName = TextEditingController();
  TextEditingController notes = TextEditingController();

  RxBool isExpenseLoading = false.obs;
  RxBool isExpenseSaveLoading = false.obs;
  RxBool isDeleteExpense = false.obs;
  RxString selectedPaymentMode = ''.obs;
  RxList<AllExpenseData> expenseList = <AllExpenseData>[].obs;

  @override
  void onInit() {
    getAllExpenses();
    super.onInit();
  }

  Future<void> saveExpense(dynamic expense) async {
    isExpenseSaveLoading.value = true;

    try {
      final response = await expenseRepo.createExpense(body: expense);
      if (response.success == success) {
        Get.back();
        clear();
        getAllExpenses();
        showSnackBar(
          error: response.message ?? "Expense Added Successfully!",
          isError: false,
        );
      } else if (response.success == failed) {
        showSnackBar(error: response.message ?? "Failed to add expense!");
      } else {
        showSnackBar(error: response.message ?? "Failed to add expense!");
      }
    } catch (e) {
      AppLogger.error('Expensed', e, 'CredtiController');
      showSnackBar(error: e.toString());
    } finally {
      isExpenseSaveLoading.value = false;
    }
  }

  Future<void> getAllExpenses() async {
    isExpenseLoading.value = true;
    try {
      final response = await expenseRepo.getExpense();
      if (response.success == success) {
        expenseList.value = response.data ?? [];
      } else if (response.success == failed) {
        showSnackBar(error: response.message ?? "Failed to get expense!");
      } else {
        showSnackBar(error: response.message ?? "Failed to get expense!");
      }
    } finally {
      isExpenseLoading.value = false;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    isDeleteExpense.value = true;
    try {
      final response = await expenseRepo.deleteExpense(expenseId: expenseId);
      if (response.success == success) {
        getAllExpenses();
        showSnackBar(
          error: response.message ?? "Expense Deleted Successfully!",
          isError: false,
        );
      } else if (response.success == failed) {
        showSnackBar(error: response.message ?? "Failed to delete expense!");
      } else {
        showSnackBar(error: response.message ?? "Failed to delete expense!");
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isDeleteExpense.value = false;
    }
  }

  void clear() {
    amount.clear();
    expensionName.clear();
    notes.clear();
    selectedPaymentMode.value = 'Cash';
  }
}
