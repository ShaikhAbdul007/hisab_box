import 'package:get/get.dart';
import 'package:inventory/module/invoice/controller/reliable_barcode_controller.dart';

class ReliableBarcodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReliableBarcodeController>(() => ReliableBarcodeController());
  }
}
