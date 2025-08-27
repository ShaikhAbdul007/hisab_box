import 'package:get/get.dart';
import 'package:inventory/module/out_of_stock/controller/out_of_stock_controller.dart';

class OutOfStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OutOfStockController());
  }
}
