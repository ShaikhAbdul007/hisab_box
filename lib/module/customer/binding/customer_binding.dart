import 'package:get/get.dart';
import 'package:inventory/module/customer/controller/customer_controller.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CustomerController());
  }
}
