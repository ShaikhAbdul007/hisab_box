import 'package:inventory/module/invoice/model/invoice_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class InvoiceRepo {
  Networking networking = Networking();

  Future<InvoiceModel> fetchInvoice({required String invoiceNo}) async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getInvoice}/$invoiceNo',
      );
      return InvoiceModel.fromJson(response);
    } catch (e) {
      return InvoiceModel(msg: e.toString(), success: false);
    }
  }
}
