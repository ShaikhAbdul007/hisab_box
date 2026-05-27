import 'package:inventory/module/setting/model/user_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class UserProfileRepo {
  Networking networking = Networking();

  Future<UserModel> updateUserDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await networking.putData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.updateProfile}',
        body: body,
      );
      return UserModel.fromJson(response);
    } catch (e) {
      return UserModel(success: false, msg: e.toString());
    }
  }

  Future<UserModel> getUserDetails() async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getProfile}',
      );
      return UserModel.fromJson(response);
    } catch (e) {
      return UserModel(success: false, msg: e.toString());
    }
  }
}
