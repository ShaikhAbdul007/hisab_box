import 'package:get/get.dart';
import 'package:inventory/module/margins/controller/marking_controller.dart';

class MarkingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MarkingController());
  }
}
