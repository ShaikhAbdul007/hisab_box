import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/module/loose_sell/model/grn_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class LoosedProductRepo {
  Networking networking = Networking();

  Future<InventoryModel> getLoosedProductData({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await networking.getData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getProducts}?page=$page&limit=$limit&location=shop&isloosed=true',
      );
      return InventoryModel.fromJson(response);
    } catch (e) {
      return InventoryModel(success: false, msg: e.toString());
    }
  }

  Future<GrnModel> getGrnData({int page = 1, int limit = 10}) async {
    try {
      final response = await networking.getData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getAllGrn}?page=$page&limit=$limit',
      );
      return GrnModel.fromJson(response);
    } catch (e) {
      return GrnModel(success: false, msg: e.toString());
    }
  }
}
