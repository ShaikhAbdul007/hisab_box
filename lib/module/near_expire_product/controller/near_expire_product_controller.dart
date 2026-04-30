import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/near_expire_product/model/near_expiry_model.dart';
import 'package:inventory/module/near_expire_product/repo/near_expiry_repo.dart';

class NearExpireProductController extends GetxController with CacheManager {
  NearExpiryRepo nearExpiryRepo = NearExpiryRepo();
  RxList<NeaExpiryItemData> nearExpProductList = <NeaExpiryItemData>[].obs;
  RxBool isDataloading = false.obs;

  @override
  void onInit() {
    getNearExpiryProducts();

    super.onInit();
  }

  Future<void> getNearExpiryProducts() async {
    try {
      var response = await nearExpiryRepo.fetchNearExpiryProducts();
      if (response.success == success) {
        nearExpProductList.value = response.data?.data ?? [];
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.error('Expiry calculation failed', e, 'NearExpireController');
      showSnackBar(error: e.toString());
    } finally {
      isDataloading.value = false;
    }
  }
}
