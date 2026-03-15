import 'package:get/get.dart';
import 'package:inventory/module/add_user/controller/add_user_controller.dart';

class AddUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddUserController());
  }
}
