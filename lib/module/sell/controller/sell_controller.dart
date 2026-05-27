import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/sell/repo/sell_repo.dart';
import '../../../helper/helper.dart';
import '../model/sell_model.dart';

class SellController extends GetxController with CacheManager {
  SellRepo sellRepo = SellRepo();
  RxBool isSellListLoading = false.obs;
  RxList<SellItemData> sellsList = <SellItemData>[].obs;
  RxString dayDates = ''.obs;

  @override
  void onInit() {
    dayDates.value = setFormateDate();
    fetchSales();
    super.onInit();
  }

  Future<void> fetchSales({String? todaysDate}) async {
    isSellListLoading.value = true;

    final selectedDate = todaysDate ?? dayDates.value;

    try {
      var response = await sellRepo.fetchSell(date: selectedDate);

      if (response.success == success) {
        sellsList.value = response.data?.data ?? [];
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info("🚨 Fetch Sales Error: $e");
      showSnackBar(error: e.toString());
    } finally {
      isSellListLoading.value = false;
    }
  }
}
