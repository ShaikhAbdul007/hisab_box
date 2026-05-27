import 'package:get/get.dart';
import 'package:inventory/module/add_user/controller/all_user_controller.dart';

class AllUserBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AllUserController());
  }
}
