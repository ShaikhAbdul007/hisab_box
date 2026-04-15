import 'package:inventory/module/auth/login/model/login_model.dart';
import 'package:inventory/module/auth/login/model/otp_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class LoginRepo {
  Networking networking = Networking();

  Future<SentOtpModel> sendOpt({required Map<String, dynamic> body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.sendOtp}',
        body: body,
      );
      return SentOtpModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginModel> verifyOtp({required Map<String, dynamic> body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.verifyOtp}',
        body: body,
      );
      return LoginModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
