import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/helper/device_info.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/gobal_controller.dart';
import 'package:open_file/open_file.dart';
import '../../../helper/helper.dart';
import '../../revenue/model/revenue_model.dart';
import '../model/product_report_model.dart';
import '../../reports/model/report_top_product_model.dart';

class ReportController extends GetxController
    with
        GetSingleTickerProviderStateMixin,
        DeviceInfoo,
        LocalService,
        CacheManager {
  final userId = SupabaseConfig.auth.currentUser?.id;
  final globalStore = Get.find<GlobalStore>();

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
  RxString reportLabels = ''.obs;
  TabController? tabController;
  RxList<ReportTopProductModel> reportTopModel = <ReportTopProductModel>[].obs;
  RxList<ReportTopProductModel> reportTopChart = <ReportTopProductModel>[].obs;
  RxList<ProductReportModel> productStockInList = <ProductReportModel>[].obs;
  var sellsList = <SellsModel>[].obs;
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
    loadInitialDataFromHive();

    // 🔥 Pehle RAM se sync karo
    syncWithGlobalStore();

    // 🔥 Listeners: Jaise hi GlobalStore mein naya bill aaye (Realtime)
    // Ye bina fetch kiye sab update kar dega
    ever(globalStore.allSalesList, (_) {
      syncWithGlobalStore();
      fetchTopSellingProducts(); // RAM calculation
      fetchTodaySalesAndProfit(); // RAM calculation
    });

    fetchData(); // Sirf initial load ke liye
    super.onInit();
  }

  // 🔥 OPTIMIZED: Ab ye Supabase call nahi karta
  void syncWithGlobalStore() {
    totalCash.value = globalStore.cashTotal.value;
    totalUpi.value = globalStore.upiTotal.value;
    totalCredit.value = globalStore.creditTotal.value;
    totalCard.value = globalStore.cardTotal.value;
    totalRevenue.value =
        totalCash.value + totalUpi.value + totalCard.value + totalCredit.value;

    // Revenue list ko bhi sync karo
    sellsList.assignAll(globalStore.allSalesList);

    _syncStatsToHive();
  }

  void loadInitialDataFromHive() {
    final stats = LocalService.getDailyReportStats();
    if (stats.isNotEmpty) {
      totalRevenue.value =
          (double.tryParse(stats['total_sales']?.toString() ?? '0.0') ?? 0.0);
      totalProfit.value =
          (double.tryParse(stats['profit']?.toString() ?? '0.0') ?? 0.0);
      totalCash.value =
          (double.tryParse(stats['cash_total']?.toString() ?? '0.0') ?? 0.0);
      totalUpi.value =
          (double.tryParse(stats['upi_total']?.toString() ?? '0.0') ?? 0.0);
      totalCard.value =
          (double.tryParse(stats['card_total']?.toString() ?? '0.0') ?? 0.0);
      totalCredit.value =
          (double.tryParse(stats['credit_total']?.toString() ?? '0.0') ?? 0.0);
    }
    final cachedTop = LocalService.getCachedTopSellingProducts();
    if (cachedTop.isNotEmpty) {
      reportTopChart.assignAll(cachedTop);
      reportTopModel.assignAll(cachedTop);
    }
  }

  void fetchData() async {
    // Initial loading ke waqt RAM data populate karo
    fetchTodaySalesAndProfit();
    fetchTopSellingProducts();
    setSellList();
  }

  Future<void> setSellList() async {
    sellsList.assignAll(globalStore.allSalesList);
  }

  void _syncStatsToHive() {
    LocalService.saveDailyReportStats({
      'total_sales': totalRevenue.value,
      'profit': totalProfit.value,
      'cash_total': totalCash.value,
      'upi_total': totalUpi.value,
      'card_total': totalCard.value,
      'credit_total': totalCredit.value,
    });
  }

  Future<void> fetchPaymentSummary() async {
    syncWithGlobalStore();
  }

  // 🔥 OPTIMIZED: Ab ye Supabase query nahi karta, RAM se profit nikalta hai
  Future<void> fetchTodaySalesAndProfit() async {
    double tempProfit = 0.0;
    for (var sale in globalStore.allSalesList) {
      for (var item in (sale.items ?? [])) {
        // GlobalStore ki product list se purchase price uthao
        var product = globalStore.allProducts.firstWhereOrNull(
          (p) => p.id == item.id,
        );
        // Note: Agar purchase_price product_stock joins mein nahi hai, toh stock_batches wali call lagani padegi
        // Filhal hum man rahe hain ki purchase_price product model mein hai
        double pPrice = 0.0; // Idher product?.purchasePrice ka logic ayega
        double sPrice = (item.finalPrice ?? 0.0).toDouble();
        int qty = (item.quantity ?? 0).toInt();
        tempProfit += (sPrice - (pPrice * qty));
      }
    }
    totalProfit.value = tempProfit;
    _syncStatsToHive();
  }

  // 🔥 OPTIMIZED: Supabase se fetch karne ki jagah RAM se aggregate karta hai
  Future<void> fetchTopSellingProductsChart() async {
    Map<String, (int, double)> agg = {};
    for (var sale in globalStore.allSalesList) {
      for (var item in (sale.items ?? [])) {
        String name = item.name ?? 'Unknown';
        int q = (item.quantity ?? 0).toInt();
        double r = (item.finalPrice ?? 0.0).toDouble();
        var curr = agg[name] ?? (0, 0.0);
        agg[name] = (curr.$1 + q, curr.$2 + r);
      }
    }

    List<ReportTopProductModel> list =
        agg.entries
            .map(
              (e) => ReportTopProductModel(
                name: e.key,
                totalQty: e.value.$1.toString(),
                revenue: e.value.$2.toInt(),
              ),
            )
            .toList();

    list.sort(
      (a, b) => int.parse(b.totalQty!).compareTo(int.parse(a.totalQty!)),
    );
    reportTopChart.assignAll(list);
  }

  Future<void> fetchTopSellingProducts() async {
    await fetchTopSellingProductsChart();
    reportTopModel.assignAll(reportTopChart);
  }

  // Future<List<SellsModel>> fetchRevenueList() -- Ye ab redundant hai kyunki GlobalStore list de raha hai
  // Par agar kahin use ho raha hai toh:
  Future<List<SellsModel>> fetchRevenueList() async {
    return globalStore.allSalesList;
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
      isExporting.value = true;
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
      showMessage(message: '$e');
    } finally {
      isExporting.value = false;
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
    var user = retrieveUserDetail();
    var excel = Excel.createExcel();
    Sheet sheet = excel[excel.getDefaultSheet()!];
    sheet.appendRow([
      TextCellValue('Shop: ${user.name}'),
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
    if (userId == null) return [];
    var range = getDateRange(
      label: label,
      customEndDate: '',
      customStartDate: '',
    );
    String start = _convertDateFormat(range.$1);
    String end = _convertDateFormat(range.$2);
    try {
      if (reportType == 'Product Stock In') {
        return await SupabaseConfig.from('stock_batches')
            .select('*, products(name, category, animal_type, weight)')
            .eq('user_id', userId!)
            .gte('purchase_date', start)
            .lte('purchase_date', end);
      } else {
        return await SupabaseConfig.from('sales')
            .select(
              '*, sale_items(*, products(name)), sale_payments(*), customers(name)',
            )
            .eq('user_id', userId!)
            .gte('created_at', "${start}T00:00:00.000Z")
            .lte('created_at', "${end}T23:59:59.999Z");
      }
    } catch (e) {
      return [];
    }
  }

  String _convertDateFormat(String ddMMyyyy) {
    try {
      List<String> p = ddMMyyyy.split('-');
      return "${p[2]}-${p[1]}-${p[0]}";
    } catch (e) {
      return ddMMyyyy;
    }
  }

  void changeTab(int index) => selectedTab.value = index;
}
