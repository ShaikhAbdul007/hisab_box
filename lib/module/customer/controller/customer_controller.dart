import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/customer/model/add_customer_model.dart';
import 'package:inventory/module/customer/model/all_customer_model.dart';
import 'package:inventory/module/customer/repo/customer_repo.dart';
import '../../order_complete/model/customer_details_model.dart';

class CustomerController extends GetxController with CacheManager {
  CustomerRepo customerRepo = CustomerRepo();

  RxBool customDataLoading = false.obs;
  RxBool isAddCustomerLoading = false.obs;
  RxBool isCustomerFetchingByMobileNumberLoading = false.obs;
  RxString searchText = ''.obs;

  RxList<CustomerItem> customerList = <CustomerItem>[].obs;

  TextEditingController searchController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  void onInit() {
    fetchAllCustomers();
    super.onInit();
  }

  void searchProduct(String value) {
    searchText.value = value;
    searchController.text = value;
  }

  void clear() {
    searchController.clear();
    searchText.value = '';
    mobileController.clear();
    addressController.clear();
    descriptionController.clear();
    nameController.clear();
  }

  double calculateTotalCredit(CustomerDetails customer) {
    return customer.totalCredit;
  }

  void setDataAsPerOptionSelected(AddCustomerData? option) {
    addressController.text = option?.address ?? '';
    nameController.text = option?.name ?? '';
    mobileController.text = option?.mobileNo ?? '';
  }

  // ================= CACHE FIRST =================
  Future<void> fetchAllCustomers() async {
    customDataLoading.value = true;
    try {
      final response = await customerRepo.getAllCustomer();
      if (response.success == success) {
        customerList.value = response.data?.customers ?? [];
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info((e).toString());
      showSnackBar(error: e.toString());
    } finally {
      customDataLoading.value = false;
    }
  }

  Future<void> addCustomers({required dynamic body}) async {
    isAddCustomerLoading.value = true;
    try {
      final response = await customerRepo.addCustomer(body: body);
      if (response.success == success) {
        Get.back();
        clear();
        showSnackBar(error: response.msg ?? 'Customer Created Successfully');
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info((e).toString());
      showSnackBar(error: e.toString());
    } finally {
      isAddCustomerLoading.value = false;
    }
  }

  Future<void> fetchCustomersByMobileNumber({required dynamic body}) async {
    isCustomerFetchingByMobileNumberLoading.value = true;
    int mobileNumber = int.parse(body);
    try {
      final response = await customerRepo.getCustomerByMobileNumber(
        mobileNumber: mobileNumber,
      );
      if (response.success == success) {
        setDataAsPerOptionSelected(response.data);
      } else if (response.success == failed) {
        // showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        // showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info((e).toString());
      showSnackBar(error: e.toString());
    } finally {
      isCustomerFetchingByMobileNumberLoading.value = false;
    }
  }
}
