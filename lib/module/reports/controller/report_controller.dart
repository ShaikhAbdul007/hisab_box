import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/device_info.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/reports/model/report_over_view_model.dart';
import 'package:inventory/module/reports/repo/report_dashboard_overview.dart';
import 'package:inventory/module/revenue/repo/revenue_repo.dart';
import 'package:inventory/module/sell/model/sell_model.dart';
import 'package:open_file/open_file.dart';
import '../../../helper/helper.dart';
import '../../revenue/model/revenue_model.dart';
import '../model/product_report_model.dart';
import '../../reports/model/report_top_product_model.dart';

class ReportController extends GetxController
    with GetSingleTickerProviderStateMixin, DeviceInfoo, CacheManager {
  ReportDashboardOverview reportDashboardOverview = ReportDashboardOverview();
  RevenueRepo revenueRepo = RevenueRepo();
  // --- Observables ---
  var selectedTab = 0.obs;
  RxDouble totalRevenue = 0.0.obs;
  RxDouble totalProfit = 0.0.obs;
  RxDouble totalCash = 0.0.obs;
  RxDouble totalUpi = 0.0.obs;
  RxDouble totalCard = 0.0.obs;
  RxDouble totalCredit = 0.0.obs;
  RxDouble totalRoundOff = 0.0.obs;
  RxInt reportDownloadGroupValue = (-1).obs;
  RxBool reportDownloadButtonEnable = false.obs;
  RxBool isExporting = false.obs;
  RxBool isDashBoardOverView = false.obs;
  RxBool isTopSellingProductsChart = false.obs;
  RxBool isTopSellingProducts = false.obs;
  RxString reportLabels = ''.obs;
  TabController? tabController;
  RxList<ReportTopProductData> reportTopModel = <ReportTopProductData>[].obs;
  RxList<ReportTopProductData> reportTopChart = <ReportTopProductData>[].obs;
  RxList<ProductReportModel> productStockInList = <ProductReportModel>[].obs;
  var sellsList = <SellItemData>[].obs;
  Rx<ReportOverviewData> reportOverViewStats = ReportOverviewData().obs;
  RxList<ReportTopProductData> reportTopProductGraph =
      <ReportTopProductData>[].obs;
  RxList<ReportTopProductData> reportTopProductList =
      <ReportTopProductData>[].obs;

  // Pagination for top products list
  int _topProductPage = 1;
  int _topProductTotalPages = 1;
  RxBool isLoadingMoreTopProducts = false.obs;
  bool get topProductHasMore => _topProductPage < _topProductTotalPages;
  RxBool isSalesLoading = false.obs;
  RxString salesDate = ''.obs;
  List<String> daysOtionLabel = ['Today', 'Week', 'Month'];
  List<String> reportLabel = [
    'Product Stock In',
    'Product Stock Out',
    'Selling with Payment',
    'Credit Amount',
  ];

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    salesDate.value = setFormateDate();
    fetchModeOfPaymentStats();
    fetchTopSellingProductsChart();
    fetchTopSellingProducts();
    fetchSales();
    super.onInit();
  }

  Future<void> fetchModeOfPaymentStats() async {
    isDashBoardOverView.value = true;
    try {
      var response = await reportDashboardOverview.getDailyOverviewData();
      if (response.success == success) {
        final d = response.data?.data;
        totalCash.value = (d?.cash ?? 0).toDouble();
        totalUpi.value = (d?.upi ?? 0).toDouble();
        totalCard.value = (d?.card ?? 0).toDouble();
        totalCredit.value = (d?.credit ?? 0).toDouble();
        totalRevenue.value = (d?.totalRevenue ?? 0).toDouble();
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isDashBoardOverView.value = false;
    }
  }

  Future<void> fetchTopSellingProductsChart() async {
    isTopSellingProductsChart.value = true;
    try {
      var response = await reportDashboardOverview.getTopProductsGraphData();
      if (response.success == success) {
        reportTopProductGraph.value = response.data ?? [];
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isTopSellingProductsChart.value = false;
    }
  }

  Future<void> fetchTopSellingProducts() async {
    _topProductPage = 1;
    reportTopProductList.clear();
    isTopSellingProducts.value = true;
    try {
      var response = await reportDashboardOverview.getTopProductsListData(
        page: _topProductPage,
      );
      if (response.success == success) {
        reportTopProductList.value = response.data ?? [];
        _topProductTotalPages = response.totalPages ?? 1;
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isTopSellingProducts.value = false;
    }
  }

  Future<void> loadMoreTopProducts() async {
    if (!topProductHasMore || isLoadingMoreTopProducts.value) return;
    _topProductPage++;
    isLoadingMoreTopProducts.value = true;
    try {
      var response = await reportDashboardOverview.getTopProductsListData(
        page: _topProductPage,
      );
      if (response.success == success) {
        reportTopProductList.addAll(response.data ?? []);
        _topProductTotalPages = response.totalPages ?? _topProductTotalPages;
      } else {
        _topProductPage--;
      }
    } catch (e) {
      _topProductPage--;
      showSnackBar(error: e.toString());
    } finally {
      isLoadingMoreTopProducts.value = false;
    }
  }

  // --- SALE TAB — reuses RevenueRepo.fetchSell (existing pattern) ---
  Future<void> fetchSales({String? date}) async {
    isSalesLoading.value = true;
    final selectedDate = getFormattedDate(date ?? salesDate.value);
    try {
      final response = await revenueRepo.fetchSell(date: selectedDate);
      if (response.success == success) {
        sellsList.value = response.data?.data ?? [];
        totalRevenue.value = (response.data?.grandTotal ?? 0).toDouble();
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isSalesLoading.value = false;
    }
  }

  // --- EXPORT LOGIC (UNCHANGED) ---
  Future<void> exportProductInReport({
    required List<dynamic> productReportModel,
    required String fileName,
    required String date,
    required String date2,
    required List<String> headers,
    required List<String> Function(dynamic item) mapper,
  }) async {
    try {
      //  isExporting.value = true;
      var file = await exportToExcel(
        date: date,
        date2: date2,
        fileName: fileName,
        headers: headers,
        dataList: productReportModel,
        mapper: mapper,
      );
      Get.back();
      showMessage(
        message: 'Report Download Successfully',
        isActionRequired: true,
        onPressed: () => OpenFile.open(file),
      );
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      //   isExporting.value = false;
    }
  }

  Future<String> exportToExcel({
    required String date,
    required String date2,
    required String fileName,
    required List<String> headers,
    required List<dynamic> dataList,
    required List<String> Function(dynamic item) mapper,
  }) async {
    //var user = retrieveUserDetail();
    var excel = Excel.createExcel();
    Sheet sheet = excel[excel.getDefaultSheet()!];
    sheet.appendRow([
      TextCellValue('Shop:'),
      TextCellValue('Report: $fileName'),
      TextCellValue('Date: $date to $date2'),
    ]);
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
    for (var element in dataList) {
      sheet.appendRow(mapper(element).map((v) => TextCellValue(v)).toList());
    }
    return await saveToDownloads(Uint8List.fromList(excel.encode()!), fileName);
  }

  Future<String> saveToDownloads(Uint8List bytes, String fileName) async {
    final downloads = Directory("/storage/emulated/0/Download");
    String filePath =
        "${downloads.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.xlsx";
    File file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  // --- MAPPERS (UNCHANGED) ---
  List<String> productStockInMapper(dynamic e) => [
    e['products']?['name'] ?? "",
    e['products']?['category'] ?? "",
    e['products']?['animal_type'] ?? "",
    e['products']?['weight'] ?? "",
    (e['quantity'] ?? 0).toString(),
    e['purchase_date'] ?? "",
    e['created_at']?.toString().split('T').last ?? "",
  ];

  List<String> productStockOutMapper(dynamic json) {
    final s = SellsModel.fromJson(json);
    final i = s.items?.isNotEmpty == true ? s.items!.first : SellItem();
    return [
      i.name ?? "",
      i.category ?? "",
      i.animalType ?? "",
      i.weight ?? "",
      (i.quantity ?? 0).toString(),
      s.soldAt ?? "",
      s.time ?? "",
    ];
  }

  List<String> sellWithPaymentMapper(dynamic json) {
    final s = SellsModel.fromJson(json);
    final i = s.items?.isNotEmpty == true ? s.items!.first : SellItem();
    return [
      s.billNo.toString(),
      i.name ?? "",
      i.barcode ?? "",
      i.category ?? "",
      i.animalType ?? "",
      (i.quantity ?? 0).toString(),
      i.weight ?? "",
      i.flavours ?? "",
      i.exprieDate ?? "",
      (i.finalPrice ?? 0).toString(),
      s.payment?.type ?? "",
      (s.payment?.cash ?? 0).toString(),
      (s.payment?.upi ?? 0).toString(),
      s.soldAt ?? "",
      s.time ?? "",
    ];
  }

  List<String> creditAmountMapper(dynamic json) {
    final s = SellsModel.fromJson(json);
    return [
      s.items?.isNotEmpty == true ? s.items!.first.name ?? "Unknown" : "N/A",
      (s.totalAmount ?? 0).toString(),
      (s.payment?.credit ?? 0).toString(),
      s.soldAt ?? "",
      s.time ?? "",
    ];
  }

  // --- REPORT HELPERS (STILL USES SUPABASE FOR HISTORICAL DATA) ---
  (String, List<String>, List<String> Function(dynamic)) getLabelValue({
    required int reportLabelIndex,
  }) {
    switch (reportLabelIndex) {
      case 0:
        return (
          "Product Stock In",
          ["Name", "Category", "Animal", "Weight", "Qty", "Date", "Time"],
          productStockInMapper,
        );
      case 1:
        return (
          "Product Stock Out",
          ["Name", "Category", "Animal", "Weight", "Qty", "Date", "Time"],
          productStockOutMapper,
        );
      case 2:
        return (
          "Sell with Payment",
          [
            "Bill",
            "Name",
            "Barcode",
            "Category",
            "Animal",
            "Qty",
            "Weight",
            "Flavor",
            "Expiry",
            "Price",
            "Mode",
            "Cash",
            "UPI",
            "Date",
            "Time",
          ],
          sellWithPaymentMapper,
        );
      case 3:
        return (
          "Credit Amount",
          ["Customer/Product", "Total Amt", "Credit Amt", "Date", "Time"],
          creditAmountMapper,
        );
      default:
        return ("Report", ["Data"], (e) => [e.toString()]);
    }
  }

  (String, String) getDateRange({
    required String label,
    required String customStartDate,
    required String customEndDate,
  }) {
    final now = DateTime.now();
    String fmt(DateTime d) =>
        "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
    if (label == 'Week') {
      return (fmt(now.subtract(Duration(days: now.weekday - 1))), fmt(now));
    }
    if (label == 'Month') {
      return (fmt(DateTime(now.year, now.month, 1)), fmt(now));
    }
    if (label == 'Custom') return (customStartDate, customEndDate);
    return (fmt(now), fmt(now));
  }

  Future<List<dynamic>> fetchProductReport({
    required String label,
    required String reportType,
  }) async {
    try {
      return [];
    } catch (e) {
      showSnackBar(error: e.toString());
      return [];
    }
  }
}
