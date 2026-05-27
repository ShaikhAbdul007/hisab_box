import 'package:inventory/module/sell/model/sell_details_model.dart';
import 'package:inventory/module/sell/model/sell_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class RevenueRepo {
  Networking networking = Networking();

  Future<SellModel> fetchSell({required String date}) async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.sell}?date=$date',
      );
      return SellModel.fromJson(response);
    } catch (e) {
      return SellModel(msg: e.toString(), success: false);
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
}
