import 'package:inventory/module/near_expire_product/model/near_expiry_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class NearExpiryRepo {
  Networking networking = Networking();
  Future<NeaExpiryModel> fetchNearExpiryProducts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await networking.getData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.nearExpiry}?days=90&$page&limit=$limit',
      );
      return NeaExpiryModel.fromJson(response);
    } catch (e) {
      return NeaExpiryModel(success: false, msg: e.toString());
    }
  }
}
