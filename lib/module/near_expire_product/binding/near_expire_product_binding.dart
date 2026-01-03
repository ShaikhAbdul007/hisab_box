import 'package:get/get.dart';
import 'package:inventory/module/near_expire_product/controller/near_expire_product_controller.dart';

class NearExpireProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NearExpireProductController());
  }
}
