import 'package:get/get.dart';

import '../controller/loose_category_controller.dart';

class LooseCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LooseCategoryController());
  }
}
