import 'package:inventory/module/revenue/model/exchange_response_model.dart';
import 'package:inventory/module/revenue/model/revenue_list_model.dart';
import 'package:inventory/module/sell/model/sell_details_model.dart';
import 'package:inventory/module/sell/model/sell_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class RevenueRepo {
  Networking networking = Networking();

  Future<RevenueListModel> fetchSell({
    required String date,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await networking.getData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.sell}?date=$date&page=$page&limit=$limit',
      );
      return RevenueListModel.fromJson(response);
    } catch (e) {
      return RevenueListModel(msg: e.toString(), success: false);
    }
  }

  Future<SellDetailsModel> fetchSellById({required String saleId}) async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.sell}/$saleId',
      );
      return SellDetailsModel.fromJson(response);
    } catch (e) {
      return SellDetailsModel(msg: e.toString(), success: false);
    }
  }

  Future<dynamic> returnSale({required Map<String, dynamic> body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.salesReturn}',
        body: body,
      );
      return response;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  Future<ExchangeResponseModel> exchangeSale({required Map<String, dynamic> body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.salesExchange}',
        body: body,
      );
      return ExchangeResponseModel.fromJson(response);
    } catch (e) {
      return ExchangeResponseModel(success: false, message: e.toString());
    }
  }
}
