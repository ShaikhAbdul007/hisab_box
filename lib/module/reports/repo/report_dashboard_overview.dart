import 'package:inventory/module/reports/model/report_over_view_model.dart';
import 'package:inventory/module/reports/model/report_top_product_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class ReportDashboardOverview {
  Networking networking = Networking();

  Future<ReportOverviewModel> getDailyOverviewData() async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.dailyOverview}',
      );
      return ReportOverviewModel.fromJson(response);
    } catch (e) {
      return ReportOverviewModel(success: false, msg: e.toString());
    }
  }

  Future<ReportTopProductModel> getTopProductsGraphData({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.reportsTopProductsGraph}',
      );
      return ReportTopProductModel.fromJson(response);
    } catch (e) {
      return ReportTopProductModel(success: false, msg: e.toString());
    }
  }

  Future<ReportTopProductModel> getTopProductsListData({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.reportsTopProductsList}',
      );
      return ReportTopProductModel.fromJson(response);
    } catch (e) {
      return ReportTopProductModel(success: false, msg: e.toString());
    }
  }
}
