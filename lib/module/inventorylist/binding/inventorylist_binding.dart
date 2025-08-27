import 'package:get/get.dart';
import 'package:inventory/module/inventorylist/controller/inventory_controller.dart';

class InventorylistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InventoryListController());
  }
}
