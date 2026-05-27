import 'package:get/get.dart';
import 'package:inventory/module/revenue/controller/details_revenue_controller.dart';

class RevenueDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DetailsRevenueController());
  }
}
