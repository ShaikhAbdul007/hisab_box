import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class InventoryScanRepo {
  Networking networking = Networking();

  Future<BarcodeExistingModel> fetchProductByBarcode({
    required String barcode,
    required String stocktype,
  }) async {
    try {
      final response = await networking.getData(
        url:
            '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getProductByBarcode}/$barcode?stocktype=$stocktype',
      );
      return BarcodeExistingModel.fromJson(response);
    } catch (e) {
      return BarcodeExistingModel(msg: e.toString(), success: false);
    }
  }
}
