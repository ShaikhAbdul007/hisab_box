import 'package:get/get.dart';
import 'package:inventory/module/invoice/controller/invoice_controller.dart';

class InvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InvoiceController());
  }
}
