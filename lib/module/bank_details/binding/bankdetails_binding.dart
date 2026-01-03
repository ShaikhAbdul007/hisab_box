import 'package:get/get.dart';
import 'package:inventory/module/bank_details/controller/bankdetails_controller.dart';

class BankdetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BankdetailsController());
  }
}
