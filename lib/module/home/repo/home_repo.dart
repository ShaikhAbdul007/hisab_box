import 'package:inventory/module/home/model/dashboard_model.dart';
import 'package:inventory/module/push_notification/local_notification_service.dart';
import 'package:inventory/module/push_notification/notification_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class HomeRepo {
  Networking networking = Networking();

  Future<DashboardModel> getDashBoardData({int page = 1}) async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.dashboard}?page=$page',
      );
      return DashboardModel.fromJson(response);
    } catch (e) {
      return DashboardModel(success: false, message: e.toString());
    }
  }

  Future<NotificationModel> saveFcmokenData(String token) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.registerFcmToken}',
        body: {'fcm_token': token},
      );
      return NotificationModel.fromJson(response);
    } catch (e) {
      return NotificationModel(success: false, message: e.toString());
    }
  }
}
