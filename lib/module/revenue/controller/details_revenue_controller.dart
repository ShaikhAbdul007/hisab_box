import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/invoice/model/invoice_model.dart';
import 'package:inventory/module/invoice/repo/invoice_repo.dart';
import 'package:inventory/module/revenue/repo/revenue_repo.dart';
import 'package:inventory/module/inventory/repo/inventory_repo.dart';
import 'package:inventory/module/revenue/model/exchange_response_model.dart';
import 'package:inventory/module/sell/model/sell_details_model.dart';

class DetailsRevenueController extends GetxController {
  RevenueRepo revenueRepo = RevenueRepo();
  InvoiceRepo invoiceRepo = InvoiceRepo();
  RxBool isRevenueListLoading = false.obs;
  RxBool isInvoiceLoading = false.obs;
  RxBool isReturnSaving = false.obs;
  RxBool isExchangeSaving = false.obs;
  RxList<SellDetailsItems> sellDataList = <SellDetailsItems>[].obs;
  var data = Get.arguments;
  RxString date = ''.obs;

  // ── Return variables ──────────────────────────────────────────────────────
  RxInt returnQty = 1.obs;
  RxString returnCondition = 'good'.obs;
  TextEditingController returnReasonController = TextEditingController();
  RxString returnPaymentMode = 'Cash'.obs;

  // ── Exchange variables ────────────────────────────────────────────────────
  RxInt exchangeReturnQty = 1.obs;
  RxString exchangeReturnCondition = 'good'.obs;
  TextEditingController exchangeReasonController = TextEditingController();
  TextEditingController exchangeBarcodeController = TextEditingController();
  RxBool isProductSearching = false.obs;
  RxList<Map<String, dynamic>> newItems = <Map<String, dynamic>>[].obs;
  RxString selectedPaymentMode = 'Cash'.obs;

  RxString status = ''.obs;

  @override
  void onInit() {
    super.onInit();
    status.value = data.status ?? '';
    AppLogger.info('saleId: ${data.saleId}');
    fetchSales(saleId: data.saleId);
  }

  void initReturnVariables() {
    returnQty.value = 1;
    returnCondition.value = 'good';
    returnReasonController.text = 'Customer request';
    returnPaymentMode.value = 'Cash';
  }

  void initExchangeVariables() {
    exchangeReturnQty.value = 1;
    exchangeReturnCondition.value = 'good';
    exchangeReasonController.text = 'Upgrade request';
    exchangeBarcodeController.clear();
    newItems.clear();
    selectedPaymentMode.value = 'Cash';
  }

  Future<void> fetchSales({required String saleId}) async {
    isRevenueListLoading.value = true;

    try {
      var response = await revenueRepo.fetchSellById(saleId: saleId);

      if (response.success == success) {
        sellDataList.value = response.data?.items ?? [];
        date.value = response.data?.dateTime ?? '';
        status.value = response.data?.status ?? '';
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

  Future<void> submitReturn({
    required String saleItemId,
    required double refundAmount,
  }) async {
    isReturnSaving.value = true;
    try {
      final body = {
        "original_sale_id": data.saleId,
        "returned_items": [
          {
            "sale_item_id": saleItemId,
            "qty": returnQty.value,
            "reason": returnReasonController.text.trim(),
            "condition": returnCondition.value,
          },
        ],
        "payments": [
          {
            "mode": returnPaymentMode.value.toLowerCase(),
            "amount": refundAmount,
          },
        ],
      };

      final response = await revenueRepo.returnSale(body: body);
      if (response != null && response['success'] == true) {
        showSnackBar(
          error: response['message'] ?? "Item returned successfully!",
          isError: false,
        );
        fetchSales(saleId: data.saleId);
      } else {
        showSnackBar(error: response?['message'] ?? "Failed to return item!");
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isReturnSaving.value = false;
    }
  }

  Future<void> submitExchange({
    required String saleItemId,
    required double diffAmount,
  }) async {
    isExchangeSaving.value = true;
    try {
      final body = {
        "original_sale_id": data.saleId,
        "returned_items": [
          {
            "sale_item_id": saleItemId,
            "qty": exchangeReturnQty.value,
            "reason": exchangeReasonController.text.trim(),
            "condition": exchangeReturnCondition.value,
          },
        ],
        "new_items":
            newItems.map((item) {
              return {
                'barcode': item['barcode'],
                'qty': item['qty'],
                'original_price': item['original_price'],
                'original_discount': item['original_discount'],
                'discounted_price': item['discounted_price'],
                'discount_given': item['discount_given'],
                'stock_type': item['stock_type'],
                'location': item['location'],
              };
            }).toList(),
        "payments": [
          {
            "mode": selectedPaymentMode.value.toLowerCase(),
            "amount": diffAmount,
          },
        ],
      };

      final response = await revenueRepo.exchangeSale(body: body);
      if (response.success == success) {
        Get.back();
        showSnackBar(
          error: response.message ?? "Exchange completed successfully!",
          isError: false,
        );
        await fetchSales(saleId: data.saleId);
      } else if (response.success == failed) {
        showSnackBar(error: response.message ?? "Failed to exchange items!");
      } else {
        showSnackBar(error: response.message ?? "Failed to exchange items!");
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isExchangeSaving.value = false;
    }
  }

  Future<void> searchExchangeBarcode(String barcode) async {
    isProductSearching.value = true;
    try {
      final scanRepo = InventoryScanRepo();
      final res = await scanRepo.fetchProductByBarcode(
        barcode: barcode,
        stocktype: '',
      );
      if (res.success == true && res.data != null) {
        final product = res.data!;
        if ((product.location ?? '').toLowerCase() != 'shop') {
          showSnackBar(error: 'Product must be in shop location.');
          return;
        }
        if ((product.quantity ?? 0) <= 0) {
          showSnackBar(error: 'Product is out of stock.');
          return;
        }

        // Add to newItems list
        final index = newItems.indexWhere((item) => item['barcode'] == barcode);
        if (index != -1) {
          if (newItems[index]['qty'] >= (product.quantity ?? 0)) {
            showSnackBar(error: 'Cannot select more than available stock.');
            return;
          }
          newItems[index]['qty']++;
          newItems.refresh();
        } else {
          newItems.add({
            'barcode': barcode,
            'qty': 1,
            'name': product.name ?? 'Unknown',
            'original_price': product.sellingPrice ?? 0.0,
            'original_discount': product.discount ?? 0,
            'discounted_price': product.sellingPrice ?? 0.0,
            'discount_given': 0,
            'stock_type': product.stockType ?? 'packet',
            'location': product.location ?? 'shop',
            'available_qty': product.quantity ?? 1,
          });
        }
        exchangeBarcodeController.clear();
      } else {
        showSnackBar(error: res.msg ?? 'Product not found.');
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isProductSearching.value = false;
    }
  }
}
