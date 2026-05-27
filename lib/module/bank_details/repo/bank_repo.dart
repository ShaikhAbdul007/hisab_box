import 'package:inventory/module/bank_details/model/bank_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class BankRepo {
  Networking networking = Networking();

  Future<BankDetailsModel> getBankDetails() async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getBankDetails}',
      );
      return BankDetailsModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<BankDetailsModel> createBankDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.createBankDetails}',
        body: body,
      );
      return BankDetailsModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
