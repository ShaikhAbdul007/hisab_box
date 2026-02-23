import 'dart:io';
import 'dart:typed_data';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 Hive Service
import 'package:inventory/helper/device_info.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/reports/model/report_top_product_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:open_file/open_file.dart';
import '../../../helper/helper.dart';
import '../../revenue/model/revenue_model.dart';
import '../model/product_report_model.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/module/revenue/model/revenue_model.dart';
import 'package:inventory/module/sell/model/sell_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/device_info.dart'; // DeviceInfoo mixin ke liye
import 'package:open_file/open_file.dart';

class ReportController extends GetxController
    with
        GetSingleTickerProviderStateMixin,
        DeviceInfoo,
        LocalService,
        CacheManager {
  final userId = SupabaseConfig.auth.currentUser?.id;
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
    loadInitialDataFromHive(); // 🔥 Instant UI Update
    fetchData();
    super.onInit();
  }

  // 🔥 Dashboard Breakdown ko turant dikhane ke liye
  void loadInitialDataFromHive() {
    final stats = LocalService.getDailyReportStats();
    if (stats.isNotEmpty) {
      // Mapping from LocalService keys to Controller variables
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
      reportTopChart.value = cachedTop;
      reportTopModel.value = cachedTop;
    }
  }

  void fetchData() async {
    await Future.wait([
      fetchTodaySalesAndProfit(),
      fetchPaymentSummary(),
      fetchTopSellingProducts(),
      fetchTopSellingProductsChart(),
      setSellList(),
    ]);
  }

  Future<void> setSellList() async {
    sellsList.value = await fetchRevenueList();
  }

  // --- INTERNAL SYNC HELPER ---
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

  // --- CORE DATA FETCH FUNCTIONS ---

  Future<void> fetchPaymentSummary() async {
    if (userId == null) return;
    final DateTime now = DateTime.now();
    final String startUtc =
        DateTime(
          now.year,
          now.month,
          now.day,
          0,
          0,
          0,
        ).toUtc().toIso8601String();
    final String endUtc =
        DateTime(
          now.year,
          now.month,
          now.day,
          23,
          59,
          59,
        ).toUtc().toIso8601String();

    try {
      final response = await SupabaseConfig.from('sales')
          .select(
            'sale_payments (cash_amount, upi_amount, card_amount, credit_amount, round_off_amount)',
          )
          .eq('user_id', userId!)
          .gte('created_at', startUtc)
          .lte('created_at', endUtc);

      double cashSum = 0, upiSum = 0, cardSum = 0, creditSum = 0, roundSum = 0;

      for (var sale in (response as List)) {
        final List payments = sale['sale_payments'] ?? [];
        for (var p in payments) {
          cashSum += (p['cash_amount'] ?? 0).toDouble();
          upiSum += (p['upi_amount'] ?? 0).toDouble();
          cardSum += (p['card_amount'] ?? 0).toDouble();
          creditSum += (p['credit_amount'] ?? 0).toDouble();
          roundSum += (p['round_off_amount'] ?? 0).toDouble();
        }
      }

      totalCash.value = cashSum;
      totalUpi.value = upiSum;
      totalCard.value = cardSum;
      totalCredit.value = creditSum;
      totalRoundOff.value = roundSum;

      _syncStatsToHive(); // 🔥 Sync Breakdown to Local Storage
    } catch (e) {
      print("🚨 Payment Summary Error: $e");
    }
  }

  Future<void> fetchTodaySalesAndProfit() async {
    if (userId == null) return;
    final DateTime now = DateTime.now();
    final String startUtc =
        DateTime(
          now.year,
          now.month,
          now.day,
          0,
          0,
          0,
        ).toUtc().toIso8601String();
    final String endUtc =
        DateTime(
          now.year,
          now.month,
          now.day,
          23,
          59,
          59,
        ).toUtc().toIso8601String();

    try {
      final response = await SupabaseConfig.from('sales')
          .select('total_amount, sale_items(qty, final_price, product_id)')
          .eq('user_id', userId!)
          .gte('created_at', startUtc)
          .lte('created_at', endUtc);

      if ((response as List).isEmpty) return;

      double tempRevenue = 0.0, tempProfit = 0.0;
      Set<String> productIds = {};

      for (var sale in response) {
        tempRevenue += (sale['total_amount'] ?? 0).toDouble();
        for (var item in (sale['sale_items'] as List)) {
          if (item['product_id'] != null) productIds.add(item['product_id']);
        }
      }

      Map<String, double> purchasePrices = {};
      if (productIds.isNotEmpty) {
        final batchResponse = await SupabaseConfig.from('stock_batches')
            .select('product_id, purchase_price')
            .inFilter('product_id', productIds.toList());
        for (var batch in (batchResponse as List)) {
          purchasePrices[batch['product_id']] =
              (batch['purchase_price'] ?? 0.0).toDouble();
        }
      }

      for (var sale in response) {
        for (var item in (sale['sale_items'] as List)) {
          double sellingPrice = (item['final_price'] ?? 0.0).toDouble();
          int qty = (item['qty'] ?? 0).toInt();
          String pid = item['product_id'] ?? '';
          double purchasePrice = purchasePrices[pid] ?? 0.0;
          tempProfit += (sellingPrice - (purchasePrice * qty));
        }
      }

      totalRevenue.value = tempRevenue;
      totalProfit.value = tempProfit;
      _syncStatsToHive();
    } catch (e) {
      print("🚨 Profit Error: $e");
    }
  }

  Future<void> fetchTopSellingProductsChart() async {
    if (userId == null) return;
    final DateTime now = DateTime.now();
    final String startUtc =
        DateTime(
          now.year,
          now.month,
          now.day,
          0,
          0,
          0,
        ).toUtc().toIso8601String();
    final String endUtc =
        DateTime(
          now.year,
          now.month,
          now.day,
          23,
          59,
          59,
        ).toUtc().toIso8601String();

    try {
      final response = await SupabaseConfig.from('sales')
          .select('id, sale_items (qty, final_price, products ( name ))')
          .eq('user_id', userId!)
          .gte('created_at', startUtc)
          .lte('created_at', endUtc);

      if ((response as List).isEmpty) {
        reportTopChart.value = [];
        return;
      }

      Map<String, (int, double)> agg = {};
      for (var sale in (response as List)) {
        final List items = sale['sale_items'] ?? [];
        for (var item in items) {
          String name = item['products']?['name'] ?? 'Unknown Product';
          int q = int.tryParse(item['qty']?.toString() ?? '0') ?? 0;
          double r =
              double.tryParse(item['final_price']?.toString() ?? '0.0') ?? 0.0;
          var current = agg[name] ?? (0, 0.0);
          agg[name] = (current.$1 + q, current.$2 + r);
        }
      }

      List<ReportTopProductModel> list =
          agg.entries.map((e) {
            return ReportTopProductModel(
              name: e.key,
              totalQty: e.value.$1.toString(),
              revenue: e.value.$2.toInt(),
            );
          }).toList();

      list.sort(
        (a, b) => (int.tryParse(b.totalQty ?? '0') ?? 0).compareTo(
          int.tryParse(a.totalQty ?? '0') ?? 0,
        ),
      );
      reportTopChart.value = list;
      await LocalService.saveTopSellingProducts(list);
    } catch (e) {
      print("🚨 Chart Error: $e");
    }
  }

  Future<void> fetchTopSellingProducts() async {
    await fetchTopSellingProductsChart();
    reportTopModel.value = List.from(reportTopChart);
  }

  Future<List<SellsModel>> fetchRevenueList() async {
    if (userId == null) return [];
    final DateTime now = DateTime.now();
    final String startUtc =
        DateTime(
          now.year,
          now.month,
          now.day,
          0,
          0,
          0,
        ).toUtc().toIso8601String();
    final String endUtc =
        DateTime(
          now.year,
          now.month,
          now.day,
          23,
          59,
          59,
        ).toUtc().toIso8601String();

    try {
      final response = await SupabaseConfig.from('sales')
          .select('''
        id, bill_no, total_amount, created_at, customer_id,
        customers (name, mobile_number),
        sale_items (qty, final_price, original_price, discount_amount, product_id, applied_discount_percent, stock_type, location, products ( name )),
        sale_payments (amount, payment_mode, reference_no, round_off_amount, cash_amount, upi_amount, card_amount, credit_amount)
      ''')
          .eq('user_id', userId!)
          .gte('created_at', startUtc)
          .lte('created_at', endUtc)
          .order('created_at', ascending: false);

      final List data = response as List;
      return data.map((sale) {
        final List dbItems = sale['sale_items'] ?? [];
        final List dbPayments = sale['sale_payments'] ?? [];

        List<SellItem> mappedItems =
            dbItems
                .map(
                  (item) => SellItem(
                    name: item['products']?['name'] ?? 'Unknown',
                    quantity: item['qty'] ?? 0,
                    originalPrice: (item['original_price'] ?? 0).toDouble(),
                    finalPrice: (item['final_price'] ?? 0).toDouble(),
                    discount: item['applied_discount_percent'] ?? 0,
                    id: item['product_id'],
                    location: item['location'] ?? 'shop',
                    sellType: item['stock_type'] ?? 'packet',
                  ),
                )
                .toList();

        double cash = 0, upi = 0, card = 0, credit = 0, roundOffTotal = 0;
        for (var p in dbPayments) {
          cash += (p['cash_amount'] ?? 0).toDouble();
          upi += (p['upi_amount'] ?? 0).toDouble();
          card += (p['card_amount'] ?? 0).toDouble();
          credit += (p['credit_amount'] ?? 0).toDouble();
          roundOffTotal += (p['round_off_amount'] ?? 0).toDouble();
        }

        return SellsModel(
          billNo: sale['bill_no'] ?? sale['id'].toString(),
          finalAmount: (sale['total_amount'] ?? 0).toDouble(),
          totalAmount: (sale['total_amount'] ?? 0).toDouble(),
          itemsCount: mappedItems.fold(
            0,
            (sum, item) => (sum ?? 0) + (item.quantity ?? 0),
          ),
          soldAt: sale['created_at'].toString().split('T')[0],
          time: sale['created_at'].toString().split('T')[1].split('.')[0],
          items: mappedItems,
          payment: PaymentModel(
            cash: cash,
            upi: upi,
            card: card,
            credit: credit,
            totalAmount: (sale['total_amount'] ?? 0).toDouble(),
            isRoundOff: roundOffTotal != 0,
            roundOffAmount: roundOffTotal,
            type:
                dbPayments.isNotEmpty
                    ? dbPayments.first['payment_mode']
                    : 'Cash',
          ),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  void changeTab(int index) => selectedTab.value = index;

  // --- EXPORT LOGIC (UNTOUCHED) ---
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
      reportDownloadButtonEnable.value = false;
      reportDownloadGroupValue.value = -1;
      reportLabels.value = '';
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

  // Mappers and Helpers
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
    if (label == 'Week')
      return (fmt(now.subtract(Duration(days: now.weekday - 1))), fmt(now));
    if (label == 'Month')
      return (fmt(DateTime(now.year, now.month, 1)), fmt(now));
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
}
