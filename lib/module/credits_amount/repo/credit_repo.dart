import 'package:inventory/module/credits_amount/model/credit_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class CreditRepo {
  Networking networking = Networking();

  Future<CreditModel> fetchCreditAmountData({
    int page = 1,
    int pageLimit = 10,
  }) async {
    try {
      final response = await networking.getData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getCreditAmountList}?page=$page&limit=$pageLimit',
      );
      return CreditModel.fromJson(response);
    } catch (e) {
      return CreditModel(message: e.toString(), success: false);
    }
  }
}
