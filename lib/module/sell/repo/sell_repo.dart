import 'package:inventory/module/sell/model/sell_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class SellRepo {
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
}
