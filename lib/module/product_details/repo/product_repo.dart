import 'package:inventory/module/product_details/model/add_product_model.dart';
import 'package:inventory/module/product_details/model/create_gr_model.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart' show Networking;

class ProductRepo {
  Networking networking = Networking();

  Future<AddProductModel> addProduct({required dynamic body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.addProduct}',
        body: body,
      );
      return AddProductModel.fromJson(response);
    } catch (e) {
      return AddProductModel(success: false, msg: e.toString());
    }
  }

  Future<AddProductModel> addLoosedProduct({required dynamic body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.addLoosedProduct}',
        body: body,
      );
      return AddProductModel.fromJson(response);
    } catch (e) {
      return AddProductModel(success: false, msg: e.toString());
    }
  }

  Future<CreateGrModel> addGrProduct({required dynamic body}) async {
    try {
      final response = await networking.postData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.baseGr}${ApiEndPoint.createGr}',
        body: body,
      );
      return CreateGrModel.fromJson(response);
    } catch (e) {
      return CreateGrModel(success: false, msg: e.toString());
    }
  }

  Future<AddProductModel> updatePacketProduct({
    required dynamic body,
    required String productId,
  }) async {
    try {
      final response = await networking.patchData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getProducts}/$productId',
        body: body,
      );
      return AddProductModel.fromJson(response);
    } catch (e) {
      return AddProductModel(success: false, msg: e.toString());
    }
  }

  Future<AddProductModel> updateLoosePacketProduct({
    required dynamic body,
  }) async {
    try {
      final response = await networking.patchData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.updateLoosedProduct}',
        body: body,
      );
      return AddProductModel.fromJson(response);
    } catch (e) {
      return AddProductModel(success: false, msg: e.toString());
    }
  }

  Future<InventoryModel> getProductListForBrand({
    int page = 1,
    int limit = 100,
    String location = 'shop',
  }) async {
    try {
      final response = await networking.getData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getProducts}?page=$page&limit=$limit&location=$location',
      );
      return InventoryModel.fromJson(response);
    } catch (e) {
      return InventoryModel(success: false, msg: e.toString());
    }
  }
}
