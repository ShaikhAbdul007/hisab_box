import 'package:get/get.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/invoice/model/invoice_model.dart';
import 'package:inventory/module/invoice/repo/invoice_repo.dart';
import 'package:inventory/module/revenue/repo/revenue_repo.dart';
import 'package:inventory/module/sell/model/sell_details_model.dart';

class DetailsRevenueController extends GetxController {
  RevenueRepo revenueRepo = RevenueRepo();
  InvoiceRepo invoiceRepo = InvoiceRepo();
  RxBool isRevenueListLoading = false.obs;
  RxBool isInvoiceLoading = false.obs;
  RxList<SellDetailsItems> sellDataList = <SellDetailsItems>[].obs;
  var data = Get.arguments;
  RxString date = ''.obs;
  @override
  void onInit() {
    super.onInit();
    print(data.billNo);
    fetchSales(saleId: data.saleId);
  }

  Future<void> fetchSales({required String saleId}) async {
    isRevenueListLoading.value = true;

    try {
      var response = await revenueRepo.fetchSellById(saleId: saleId);

      if (response.success == success) {
        sellDataList.value = response.data?.items ?? [];
        date.value = response.data?.dateTime ?? '';
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info("🚨 Fetch Sales Error: $e");
      showSnackBar(error: e.toString());
    } finally {
      isRevenueListLoading.value = false;
    }
  }

  Future<InvoiceModel> fetchInvoice({required String invoiceNo}) async {
    isInvoiceLoading.value = true;

    try {
      var response = await invoiceRepo.fetchInvoice(invoiceNo: invoiceNo);
      return response;
    } catch (e) {
      AppLogger.info("🚨 Fetch Sales Error: $e");
      showSnackBar(error: e.toString());
      return InvoiceModel();
    } finally {
      isInvoiceLoading.value = false;
    }
  }
}
