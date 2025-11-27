import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';

class AppSettingController extends GetxController with CacheManager {
  RxBool isInventoryScanSelected = false.obs;

  @override
  void onInit() {
    isInventoryScanSelectedValue();
    super.onInit();
  }

  void isInventoryScanSelectedValue() async {
    bool isInventoryScanSelecteds = await retrieveInventoryScan();

    isInventoryScanSelected.value = isInventoryScanSelecteds;
  }
}
