
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class HomeRepo {
  Networking networking = Networking();

  Future<BankDetailsModel> getDashBoardData({required dynamic body}) async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.dashboard}',
        body:body
      );
      return BankDetailsModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

}