import 'package:get/get.dart';
import 'package:inventory/module/revenue/model/revenue_model.dart';
import 'package:inventory/module/sell/model/sell_model.dart';

class DetailsRevenueController extends GetxController {
  late SellItemData sellModels;

  var data = Get.arguments;

  List<SellItemData> sellDataList = [];

  @override
  void onInit() {
    sellModels = data;
    sellDataList = data;
    super.onInit();
  }
}
