import 'package:inventory/module/auth/login/model/otp_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class LogoutRepo {
  Networking networking = Networking();

  Future<SentOtpModel> logout() async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.logout}',
        body: {},
      );
      return SentOtpModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
