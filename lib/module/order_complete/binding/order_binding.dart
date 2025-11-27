import 'package:get/get.dart';
import 'package:inventory/module/order_complete/controller/order_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderController());
  }
}
