import 'package:get/get.dart';
import 'package:inventory/module/invoice_barcode_designer/controller/invoice_designer_controller.dart';

class InvoiceDesignerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InvoiceDesignerController());
  }
}
