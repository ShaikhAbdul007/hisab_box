import 'package:get/get.dart';
import '../controller/color_category_controller.dart';

class ColorCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ColorCategoryController());
  }
}
