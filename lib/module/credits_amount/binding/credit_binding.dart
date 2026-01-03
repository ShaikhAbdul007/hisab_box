import 'package:get/get.dart';
import 'package:inventory/module/credits_amount/controller/credit_controller.dart';

class CreditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CredtiController());
  }
}
