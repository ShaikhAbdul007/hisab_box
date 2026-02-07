import 'dart:io';
import 'dart:typed_data';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/device_info.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/reports/model/report_top_product_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../helper/helper.dart';
import '../../revenue/model/revenue_model.dart';
import '../model/product_report_model.dart';

class ReportController extends GetxController
    with GetSingleTickerProviderStateMixin, DeviceInfoo, CacheManager {
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
    fetchData();
    super.onInit();
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

  // Helper for Date Logic
  (String, String) _getTodayRange() {
    String today = setFormateDate();
    List<String> p = today.split('-');
    String iso = "${p[2]}-${p[1]}-${p[0]}";
    return ("${iso}T00:00:00.000Z", "${iso}T23:59:59.999Z");
  }

  String _convertDateFormat(String ddMMyyyy) {
    try {
      List<String> p = ddMMyyyy.split('-');
      return "${p[2]}-${p[1]}-${p[0]}";
    } catch (e) {
      return ddMMyyyy;
    }
  }

  // --- CORE DATA FETCH FUNCTIONS ---

  Future<void> fetchPaymentSummary() async {
    if (userId == null) return;
    final range = _getTodayRange();

    try {
      // Hum 'sales' table se query shuru karenge kyunki user_id wahan hai
      final response = await SupabaseConfig.from('sales')
          .select('sale_payments (amount, payment_mode)')
          .eq('user_id', userId!)
          .gte('created_at', range.$1)
          .lte('created_at', range.$2);

      totalCash.value = 0.0;
      totalUpi.value = 0.0;
      totalCard.value = 0.0;
      totalCredit.value = 0.0;

      for (var sale in response) {
        final List payments = sale['sale_payments'] ?? [];
        for (var p in payments) {
          final mode = p['payment_mode']?.toString().toLowerCase() ?? '';
          final amount = (p['amount'] ?? 0).toDouble();
          if (mode == 'cash') {
            totalCash.value += amount;
          } else if (mode == 'upi') {
            totalUpi.value += amount;
          } else if (mode == 'card') {
            totalCard.value += amount;
          } else if (mode == 'credit') {
            totalCredit.value += amount;
          }
        }
      }
    } catch (e) {
      customMessageOrErrorPrint(message: "Payment Summary Error: $e");
    }
  }

  Future<void> fetchTodaySalesAndProfit() async {
    if (userId == null) return;
    final range = _getTodayRange();
    totalProfit.value = 0.0;
    totalRevenue.value = 0.0;

    try {
      final response = await SupabaseConfig.from('sales')
          .select('total_amount, sale_items(qty, final_price, product_id)')
          .eq('user_id', userId!)
          .gte('created_at', range.$1)
          .lte('created_at', range.$2);

      for (var sale in response) {
        totalRevenue.value += (sale['total_amount'] ?? 0).toDouble();
        final List items = sale['sale_items'] ?? [];

        for (var item in items) {
          double sellingPrice = (item['final_price'] ?? 0).toDouble();
          int qty = (item['qty'] ?? 0).toInt();
          String? pid = item['product_id'];

          if (pid != null) {
            // Har product ki purchase price stock_batches se uthao
            final batchData =
                await SupabaseConfig.from('stock_batches')
                    .select('purchase_price')
                    .eq('product_id', pid)
                    .limit(1)
                    .maybeSingle();

            double purchasePrice =
                (batchData?['purchase_price'] ?? 0).toDouble();
            totalProfit.value += (sellingPrice - (purchasePrice * qty));
          }
        }
      }
    } catch (e) {
      customMessageOrErrorPrint(message: "Profit Error: $e");
    }
  }

  Future<void> fetchTopSellingProductsChart() async {
    if (userId == null) return;
    final range = _getTodayRange();

    try {
      // 1. Sales table se query start karo taaki filter sahi lage
      final response = await SupabaseConfig.from('sales')
          .select('''
            id,
            sale_items (
              qty,
              final_price,
              products ( name )
            )
          ''')
          .eq('user_id', userId!)
          .gte('created_at', range.$1)
          .lte('created_at', range.$2);

      if (response == null || (response as List).isEmpty) {
        reportTopChart.value = [];
        return;
      }

      Map<String, (int, double)> agg = {};

      // 2. Data ko loop karke aggregate karo
      for (var sale in response) {
        final List items = sale['sale_items'] ?? [];
        for (var item in items) {
          // Products ka naam andar se nikalo
          String name = item['products']?['name'] ?? 'Unknown';
          int q = (item['qty'] ?? 0).toInt();
          double r = (item['final_price'] ?? 0.0).toDouble();

          var current = agg[name] ?? (0, 0.0);
          agg[name] = (current.$1 + q, current.$2 + r);
        }
      }

      // 3. Model mein map karo aur UI update karo
      reportTopChart.value =
          agg.entries
              .map(
                (e) => ReportTopProductModel(
                  name: e.key,
                  totalQty: e.value.$1.toString(),
                  revenue: e.value.$2.toInt(),
                ),
              )
              .toList();

      // Sort kar do taaki top selling upar aaye
      reportTopChart.sort(
        (a, b) => int.parse(b.totalQty!).compareTo(int.parse(a.totalQty!)),
      );
    } catch (e) {
      customMessageOrErrorPrint(message: "Chart Error: $e");
      reportTopChart.value = [];
    }
  }

  Future<void> fetchTopSellingProducts() async {
    await fetchTopSellingProductsChart();
    reportTopModel.value = List.from(reportTopChart);
  }

  Future<List<SellsModel>> fetchRevenueList() async {
    if (userId == null) return [];

    final DateTime now = DateTime.now();
    final String startOfToday =
        DateTime(now.year, now.month, now.day).toIso8601String();
    final String endOfToday =
        DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    try {
      // Query ekdum saaf kar di hai, koi extra comment ya symbol nahi hai
      final response = await SupabaseConfig.from('sales')
          .select('''
          id,
          bill_no,
          total_amount,
          created_at,
          customer_id,
          customers (name, mobile_number),
          sale_items (
            qty,
            final_price,
            original_price,
            discount_amount,
            product_id,
            applied_discount_percent,
            stock_type,
            location,
            products ( name )
          ),
          sale_payments (
            amount,
            payment_mode,
            reference_no
          )
        ''')
          .eq('user_id', userId!)
          .gte('created_at', startOfToday)
          .lte('created_at', endOfToday)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List;

      return data.map((sale) {
        final List<dynamic> dbItems = sale['sale_items'] ?? [];
        final List<dynamic> dbPayments = sale['sale_payments'] ?? [];

        // Mapping logic (Variable names wahi hain jo aapne mange the)
        List<SellItem> mappedItems =
            dbItems.map((item) {
              return SellItem(
                name: item['products']?['name'] ?? 'Unknown',
                quantity: item['qty'] ?? 0,
                originalPrice: (item['original_price'] ?? 0).toDouble(),
                finalPrice: (item['final_price'] ?? 0).toDouble(),
                discount: item['applied_discount_percent'] ?? 0,
                barcode: '',
                id: item['product_id'],
                location: item['location'] ?? 'shop',
                sellType: item['stock_type'] ?? 'packet',
              );
            }).toList();

        double cash = 0, upi = 0, card = 0, credit = 0;
        for (var p in dbPayments) {
          String mode = p['payment_mode']?.toString().toLowerCase() ?? '';
          double amt = (p['amount'] ?? 0).toDouble();
          if (mode == 'cash') {
            cash += amt;
          } else if (mode == 'upi') {
            upi += amt;
          } else if (mode == 'card') {
            card += amt;
          } else if (mode == 'credit') {
            credit += amt;
          }
        }

        PaymentModel paymentObj = PaymentModel(
          cash: cash,
          upi: upi,
          card: card,
          credit: credit,
          totalAmount: (sale['total_amount'] ?? 0).toDouble(),
          isRoundOff: false,
          roundOffAmount: 0.0,
          type:
              dbPayments.isNotEmpty ? dbPayments.first['payment_mode'] : 'Cash',
        );

        return SellsModel(
          billNo: sale['bill_no']?.toString() ?? sale['id'].toString(),
          finalAmount: (sale['total_amount'] ?? 0).toDouble(),
          totalAmount: (sale['total_amount'] ?? 0).toDouble(),
          itemsCount: mappedItems.fold(
            0,
            (sum, item) => (sum ?? 0) + (item.quantity ?? 0),
          ),
          soldAt: sale['created_at'].toString().split('T')[0],
          time: sale['created_at'].toString().split('T')[1].split('.')[0],
          items: mappedItems,
          payment: paymentObj,
          isDiscountGiven: false,
          discountValue: 0.0,
        );
      }).toList();
    } catch (e) {
      print("🚨 Revenue List Error: $e");
      return [];
    }
  }

  Future<void> setSellList() async {
    sellsList.value = await fetchRevenueList();
  }

  void changeTab(int index) => selectedTab.value = index;

  // --- EXPORT & FILE LOGIC ---

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

  // --- REPORT MAPPERS (FOR EXCEL) ---

  List<String> productStockInMapper(dynamic e) {
    return [
      e['products']?['name'] ?? "",
      e['products']?['category'] ?? "",
      e['products']?['animal_type'] ?? "",
      e['products']?['weight'] ?? "",
      (e['quantity'] ?? 0).toString(),
      e['purchase_date'] ?? "",
      e['created_at']?.toString().split('T').last ?? "",
    ];
  }

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
      s.billNo ?? "",
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

  // --- CORE UTILITIES ---

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
}
