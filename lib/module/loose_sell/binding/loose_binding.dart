import 'package:get/get.dart';

import '../controller/loose_controller.dart';

class LooseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LooseController());
  }
}
