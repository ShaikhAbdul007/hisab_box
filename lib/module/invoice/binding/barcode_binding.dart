import 'package:get/get.dart';

import '../controller/bardcode_controller.dart';

class BarcodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BardcodeController());
  }
}
