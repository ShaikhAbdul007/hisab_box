import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/logger.dart';

class AppSettingController extends GetxController with CacheManager {
  RxBool isInventoryScanSelected = false.obs;

  @override
  void onInit() {
    isInventoryScanSelectedValue();
    super.onInit();
  }

  Future<void> isInventoryScanSelectedValue() async {
    try {
      bool isInventoryScanSelecteds = await retrieveInventoryScan();
      isInventoryScanSelected.value = isInventoryScanSelecteds;
    } catch (e) {
      AppLogger.error(
        'Failed to read inventory scan setting',
        e,
        'AppSettingController',
      );
      isInventoryScanSelected.value = false;
    }
  }
}
