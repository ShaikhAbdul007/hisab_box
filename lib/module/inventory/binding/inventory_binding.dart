import 'package:get/get.dart';

import '../controller/inventroy_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => InventroyController());
  }
}
