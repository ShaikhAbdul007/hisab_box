import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/revenue/repo/revenue_repo.dart';
import 'package:inventory/module/sell/model/sell_model.dart';

class RevenueController extends GetxController {
  RevenueRepo revenueRepo = RevenueRepo();
  RxBool isRevenueListLoading = false.obs;
  var sellsList = <SellItemData>[].obs;
  RxDouble sellTotalAmount = 0.0.obs;
  RxString dayDate = ''.obs;

  @override
  void onInit() {
    dayDate.value = setFormateDate();
    setSellList();
    super.onInit();
  }

  void setSellList() async {
    await fetchSales();
  }

  Future<void> fetchSales({String? todaysDate}) async {
    isRevenueListLoading.value = true;

    final selectedDate = getFormattedDate(todaysDate ?? dayDate.value);

    try {
      var response = await revenueRepo.fetchSell(date: selectedDate);

      if (response.success == success) {
        sellsList.value = response.data?.data ?? [];
        sellTotalAmount.value = response.data?.grandTotal?.toDouble() ?? 0.0;
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info("🚨 Fetch Sales Error: $e");
      showSnackBar(error: e.toString());
    } finally {
      isRevenueListLoading.value = false;
    }
  }
}
