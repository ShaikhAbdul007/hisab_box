import 'package:inventory/module/product_details/model/add_product_model.dart';
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
}
