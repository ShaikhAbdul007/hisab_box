import 'package:inventory/module/credits_amount/model/credit_model.dart';
import 'package:inventory/module/expense/model/all_expense_model.dart';
import 'package:inventory/module/expense/model/expens_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class ExpenseRepo {
  Networking networking = Networking();

  Future<AllExpenseModel> getExpense() async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getExpense}',
      );
      return AllExpenseModel.fromJson(response);
    } catch (e) {
      return AllExpenseModel(success: false, message: e.toString());
    }
  }

  Future<ExpanseModel> createExpense({required dynamic body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.createExpense}',
        body: body,
      );
      return ExpanseModel.fromJson(response);
    } catch (e) {
      return ExpanseModel(message: e.toString(), success: false);
    }
  }

  Future<ExpanseModel> deleteExpense({required String expenseId}) async {
    try {
      final response = await networking.deleteData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.createExpense}/$expenseId',
      );
      return ExpanseModel.fromJson(response);
    } catch (e) {
      return ExpanseModel(message: e.toString(), success: false);
    }
  }
}
