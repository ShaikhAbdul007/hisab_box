import 'package:inventory/module/customer/model/add_customer_model.dart';
import 'package:inventory/module/customer/model/all_customer_model.dart';
import 'package:inventory/network/api_endpoint.dart';
import 'package:inventory/network/networking.dart';

class CustomerRepo {
  Networking networking = Networking();

  Future<AddCustomerModel> addCustomer({required dynamic body}) async {
    try {
      final response = await networking.postData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.addCustomer}',
        body: body,
      );
      return AddCustomerModel.fromJson(response);
    } catch (e) {
      return AddCustomerModel(msg: e.toString(), success: false);
    }
  }

  Future<AllCustomerModel> getAllCustomer() async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getAllCustomer}',
      );
      return AllCustomerModel.fromJson(response);
    } catch (e) {
      return AllCustomerModel(msg: e.toString(), success: false);
    }
  }

  Future<AddCustomerModel> getCustomerByMobileNumber({
    required int mobileNumber,
  }) async {
    try {
      final response = await networking.getData(
        url: '${ApiEndPoint.fullBaseUrl}${ApiEndPoint.getCustomerMobileNumber}$mobileNumber',
        
      );
      return AddCustomerModel.fromJson(response);
    } catch (e) {
      return AddCustomerModel(msg: e.toString(), success: false);
    }
  }
}
