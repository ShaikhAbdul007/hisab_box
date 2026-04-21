import 'package:inventory/module/home/model/dashboard_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class HomeRepo {
  Networking networking = Networking();

  Future<DashboardModel> getDashBoardData() async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.dashboard}',
    
      );
      return DashboardModel.fromJson(response);
    } catch (e) {
      return DashboardModel(success: false, message: e.toString());
    }
  }
}
