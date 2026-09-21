import 'package:get/get.dart';
import '../controller/easy_billing_controller.dart';

class EasyBillingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EasyBillingController>(() => EasyBillingController());
  }
}
