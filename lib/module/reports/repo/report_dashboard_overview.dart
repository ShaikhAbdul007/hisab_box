import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/reports/model/report_over_view_model.dart';
import 'package:inventory/module/reports/model/report_top_product_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class ReportDashboardOverview {
  Networking networking = Networking();

  Future<ReportOverviewModel> getDailyOverviewData({String? date}) async {
    try {
      final String d = date ?? todayApiDate();
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.dailyOverview}?date=$d',
      );
      return ReportOverviewModel.fromJson(response);
    } catch (e) {
      return ReportOverviewModel(success: false, msg: e.toString());
    }
  }

  Future<ReportTopProductModel> getTopProductsGraphData({
    int page = 1,
    int limit = 10,
    String? date,
  }) async {
    try {
      final String d = date ?? todayApiDate();
      final response = await networking.getData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.reportsTopProductsGraph}?date=$d&limit=$limit',
      );
      return ReportTopProductModel.fromJson(response);
    } catch (e) {
      return ReportTopProductModel(success: false, msg: e.toString());
    }
  }

  Future<ReportTopProductModel> getTopProductsListData({
    int page = 1,
    int limit = 10,
    String? date,
  }) async {
    try {
      final String d = date ?? todayApiDate();
      final response = await networking.getData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.reportsTopProductsList}?date=$d&page=$page&limit=$limit',
      );
      return ReportTopProductModel.fromJson(response);
    } catch (e) {
      return ReportTopProductModel(success: false, msg: e.toString());
    }
  }
}
