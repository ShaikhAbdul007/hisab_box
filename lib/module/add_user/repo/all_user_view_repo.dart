import 'package:inventory/module/add_user/model/employee_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class AllUserViewRepo {
  Networking networking = Networking();

  Future<EmpolyeeModel> getEmployees() async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getEmployees}',
      );
      return EmpolyeeModel.fromJson(response);
    } catch (e) {
      return EmpolyeeModel(msg: e.toString(), success: false);
    }
  }
}
