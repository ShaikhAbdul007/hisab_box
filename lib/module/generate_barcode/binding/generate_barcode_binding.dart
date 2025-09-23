import 'package:get/get.dart';

import '../controller/generate_barcode_controller.dart';

class GenerateBarcodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GenerateBarcodeController());
  }
}
