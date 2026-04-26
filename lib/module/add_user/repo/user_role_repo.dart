import 'package:inventory/module/add_user/model/add_user_role.dart';
import 'package:inventory/module/add_user/model/all_user_role_model.dart';
import 'package:inventory/module/add_user/model/employee_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class UserRoleRepo {
  Networking networking = Networking();

  Future<AllUserRoleModel> getAllUserRole() async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getAllUserRoles}',
      );
      return AllUserRoleModel.fromJson(response);
    } catch (e) {
      return AllUserRoleModel(msg: e.toString(), success: false);
    }
  }

  Future<AddUserRole> createUserRole({required dynamic body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.createUserRoles}',
        body: body,
      );
      return AddUserRole.fromJson(response);
    } catch (e) {
      return AddUserRole(msg: e.toString(), success: false);
    }
  }

  Future<AddUserRole> deleteUserRole({required String id}) async {
    try {
      final response = await networking.deleteData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.deleteUserRoles}/$id',
      );
      return AddUserRole.fromJson(response);
    } catch (e) {
      return AddUserRole(msg: e.toString(), success: false);
    }
  }
}
