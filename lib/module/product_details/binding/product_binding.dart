import 'package:get/get.dart';
import 'package:inventory/module/product_details/controller/controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductController());
  }
}
