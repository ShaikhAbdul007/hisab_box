import 'package:get/get.dart';

class GobalBinding extends Bindings {
  @override
  void dependencies() {
    // 🔥 Direct instance pass karo permanent load ke liye
    // Get.put(GlobalStore(), permanent: true);
  }
}
