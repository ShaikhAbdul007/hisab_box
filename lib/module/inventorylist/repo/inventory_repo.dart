import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class InventoryRepo {
  Networking networking = Networking();

  Future<InventoryModel> getProductData({
    int page = 1,
    int limit = 10,
    required String search,
  }) async {
    try {
      final response = await networking.getData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getProducts}?page=$page&limit=$limit&search&location=$search',
      );
      return InventoryModel.fromJson(response);
    } catch (e) {
      return InventoryModel(success: false, msg: e.toString());
    }
  }
}
