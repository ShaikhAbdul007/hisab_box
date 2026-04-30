import 'package:get/get.dart';
import 'package:inventory/module/gobal_module/gobal_controller.dart';

class GobalBinding extends Bindings {
  @override
  void dependencies() {
    // 🔥 Direct instance pass karo permanent load ke liye
    // Get.put(GlobalStore(), permanent: true);
  }
}
