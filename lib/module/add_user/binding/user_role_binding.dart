



import 'package:get/get.dart';
import 'package:inventory/module/add_user/controller/user_role_controller.dart';

class UserRoleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserRoleController());
  }
}