import 'package:get/get.dart';

import '../controller/discount_controller.dart';

class DiscountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DiscountController());
  }
}
