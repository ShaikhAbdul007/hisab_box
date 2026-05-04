import 'package:inventory/helper/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/customer/model/all_customer_model.dart';
import 'package:inventory/module/customer/repo/customer_repo.dart';
import 'package:inventory/module/invoice/model/invoice_model.dart';
import 'package:inventory/module/invoice/repo/invoice_repo.dart';

class OrderController extends GetxController with CacheManager {
  InvoiceRepo invoiceRepo = InvoiceRepo();
  CustomerRepo customerRepo = CustomerRepo();

  TextEditingController mobileNumber = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController description = TextEditingController();

  RxList<CustomerItem> customerDetails = <CustomerItem>[].obs;
  RxBool saveCustomerWithInvoiceLoading = false.obs;
  RxBool homeButtonVisible = true.obs;
  RxBool isInvoiceLoading = false.obs;
  Rx<InvoiceData?> invoiceData = Rx<InvoiceData?>(null);

  var data = Get.arguments;

  @override
  void onInit() {
    if (data != null) {
      _fetchInvoice();
      _checkCreditFromInvoice();
    }
    _loadCustomers();
    super.onInit();
  }

  /// Re-check after invoiceData loads — payments list se credit mode check
  void _checkCreditFromInvoice() {
    final payments = invoiceData.value?.payments ?? [];
    final hasCredit = payments.any(
      (p) =>
          (p.mode ?? '').toLowerCase() == 'credit' &&
          (double.tryParse(p.amount ?? '0') ?? 0) > 0,
    );
    homeButtonVisible.value = !hasCredit;
  }

  Future<void> _fetchInvoice() async {
    final billNo = data.billNo;
    if (billNo.isEmpty) return;
    isInvoiceLoading.value = true;
    try {
      final response = await invoiceRepo.fetchInvoice(invoiceNo: billNo);
      if (response.success == true && response.data != null) {
        invoiceData.value = response.data;
        _checkCreditFromInvoice();
      }
    } catch (e) {
      AppLogger.info(("🚨 Invoice fetch error: $e").toString());
    } finally {
      isInvoiceLoading.value = false;
    }
  }

  Future<void> _loadCustomers() async {
    try {
      final response = await customerRepo.getAllCustomer();
      if (response.success == true) {
        customerDetails.value = response.data?.customers ?? [];
      }
    } catch (e) {
      AppLogger.info(("Error loading customers: $e").toString());
    }
  }

  Future<bool> saveCustomerWithInvoice({required InvoiceModel invoice}) async {
    saveCustomerWithInvoiceLoading.value = true;

    //sale_id

    try {
      return true;
    } catch (e) {
      AppLogger.info(("🚨 Save Customer Error Details: $e").toString());
      showSnackBar(error: e.toString());
      return false;
    } finally {
      saveCustomerWithInvoiceLoading.value = false;
    }
  }

  void setDataAsPerOptionSelected(CustomerItem option) {
    address.text = option.address ?? '';
    name.text = option.name ?? '';
    mobileNumber.text = option.mobileNo ?? '';
  }

  void clear() {
    name.clear();
    address.clear();
    mobileNumber.clear();
    description.clear();
  }
}
