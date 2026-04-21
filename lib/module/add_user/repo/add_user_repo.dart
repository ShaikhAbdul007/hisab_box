import 'package:inventory/module/add_user/model/add_empolyee_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class AddUserRepo {
  Networking networking = Networking();

  Future<AddEmpolyeeModel> addEmployees({required dynamic body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.addEmployees}',
        body: body,
      );
      return AddEmpolyeeModel.fromJson(response);
    } catch (e) {
      return AddEmpolyeeModel(msg: e.toString(), success: false);
    }
  }

  Future<AddEmpolyeeModel> updateEmployees({
    required dynamic body,
    required String employeeId,
  }) async {
    try {
      final response = await networking.postData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getEmployees}/$employeeId/${ApiEndPoint.updateEmployeesPermissions}',
        body: body,
      );
      return AddEmpolyeeModel.fromJson(response);
    } catch (e) {
      return AddEmpolyeeModel(msg: e.toString(), success: false);
    }
  }
}
