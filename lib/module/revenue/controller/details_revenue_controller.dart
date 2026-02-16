import 'package:get/get.dart';
import 'package:inventory/module/revenue/model/revenue_model.dart';

class DetailsRevenueController extends GetxController {
  late SellsModel sellModels;

  var data = Get.arguments;

  List<SellItem> sellDataList = [];

  @override
  void onInit() {
    sellModels = data;
    sellDataList = data.items ?? [];
    super.onInit();
  }
}
