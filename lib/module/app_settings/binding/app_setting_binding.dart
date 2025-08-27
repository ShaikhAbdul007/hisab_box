import 'package:get/get.dart';
import 'package:inventory/module/app_settings/controller/app_setting_controller.dart';

class AppSettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppSettingController());
  }
}
