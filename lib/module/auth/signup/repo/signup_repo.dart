import 'package:inventory/module/setting/model/user_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class SignupRepo {
  Networking networking = Networking();

  Future<UserModel> signUp({required Map<String, dynamic> body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.baseUrl}${ApiEndPoint.registerUser}',
        body: body,
      );
      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
