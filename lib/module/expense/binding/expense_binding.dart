import 'package:get/get.dart';
import 'package:inventory/module/expense/controller/expense_controller.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExpenseController());
  }
}
