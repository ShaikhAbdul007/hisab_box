import 'package:get/get.dart';

import '../controller/sell_list_after_scan_controller.dart';

class SellListAfterScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SellListAfterScanController());
  }
}
