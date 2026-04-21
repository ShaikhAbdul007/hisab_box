import 'package:get/get.dart';
import 'package:inventory/module/add_user/controller/all_user_detail_controller.dart';

class AllUserDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AllUserDetailController());
  }
}
