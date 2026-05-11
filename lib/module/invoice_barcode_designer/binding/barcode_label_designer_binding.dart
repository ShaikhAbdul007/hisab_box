import 'package:get/get.dart';
import 'package:inventory/module/invoice_barcode_designer/controller/barcode_label_designer_controller.dart';

class BarcodeLabelDesignerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BarcodeLabelDesignerController());
  }
}
