import 'dart:io';

import 'package:inventory/module/setting/model/user_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';
class SignupRepo {
  final Networking networking = Networking();

  Future<UserModel> signUp({
    required Map<String, String> body,
    File? profilePic,
  }) async {
    try {
      final response = await networking.postMultipartRequestData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.registerUser}',
        body: body,
        fileField: "profilepic",
        file: profilePic,
        fileName: profilePic?.path.split('/').last,
        requiresAuth: false, // Registration doesn't need auth token
      );

      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}