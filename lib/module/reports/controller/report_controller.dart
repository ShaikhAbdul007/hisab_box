import 'dart:io';
import 'dart:typed_data';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/device_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/reports/model/report_top_product_model.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../helper/helper.dart';
import '../../revenue/model/revenue_model.dart';
import '../model/product_report_model.dart';

class ReportController extends GetxController
    with GetSingleTickerProviderStateMixin, DeviceInfoo, CacheManager {
  final uid = FirebaseAuth.instance.currentUser?.uid;
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
    await fetchTodaySalesAndProfit();
    await fetchTopSellingProducts();
    await fetchTopSellingProductsChart();
    await fetchPaymentSummary();
    await setSellList();
  }

  Future<void> fetchPaymentSummary() async {
    if (uid == null) {
      totalCash.value = 0.0;
      totalUpi.value = 0.0;
      totalCard.value = 0.0;
      totalCredit.value = 0.0;
      totalRoundOff.value = 0.0;
    }

    String today = setFormateDate();

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('sales')
              .where('soldAt', isEqualTo: today)
              .get();

      for (var doc in snapshot.docs) {
        var data = doc.data();

        var pay = data['payment'] ?? {};

        totalCash.value += (pay['cash'] ?? 0).toDouble();
        totalUpi.value += (pay['upi'] ?? 0).toDouble();
        totalCard.value += (pay['card'] ?? 0).toDouble();
        totalCredit.value += (pay['credit'] ?? 0).toDouble();
        totalRoundOff.value += (pay['roundOffAmount'] ?? 0).toDouble();

        //totalRevenue += (data['finalAmount'] ?? 0).toDouble();
      }
    } catch (e) {
      customMessageOrErrorPrint(message: "Payment Summary Error: $e");
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> setSellList() async {
    sellsList.value = await fetchRevenueList();
  }

  Future<void> fetchTodaySalesAndProfit() async {
    String today = setFormateDate();

    totalProfit.value = 0.0;
    totalRevenue.value = 0.0;

    if (uid == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('sales')
              .where('soldAt', isEqualTo: today)
              .get();

      if (snapshot.docs.isEmpty) return;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // ---------- REVENUE -----------
        double saleAmount = (data['finalAmount'] ?? 0).toDouble();
        totalRevenue.value += saleAmount;

        // ---------- PROFIT CALCULATION ----------
        List items = data["items"] ?? [];

        for (var item in items) {
          double finalPrice =
              (item["finalPrice"] ?? 0).toDouble(); // TOTAL SELLING
          double costPP =
              (item["purchasePrice"] ?? 0).toDouble(); // COST PER PIECE
          int qty = (item["quantity"] ?? 1).toInt();

          double totalCost = costPP * qty;
          double profit = finalPrice - totalCost;

          totalProfit.value += profit;
        }
      }
    } catch (e) {
      customMessageOrErrorPrint(message: "Error: $e");
      totalProfit.value = 0.0;
      totalRevenue.value = 0.0;
    }
  }

  Future<void> fetchTopSellingProductsChart() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) reportTopChart.value = [];

    String today = setFormateDate();

    Map<String, int> qtyMap = {};
    Map<String, double> revenueMap = {};

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('sales')
              .where('soldAt', isEqualTo: today)
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        List items = data["items"] ?? [];

        for (var item in items) {
          String name = item["name"] ?? "Unknown";
          int qty = (item["quantity"] ?? 1).toInt();
          double price = (item["finalPrice"] ?? 0).toDouble();

          qtyMap[name] = (qtyMap[name] ?? 0) + qty;
          revenueMap[name] = (revenueMap[name] ?? 0) + (price * qty);
        }
      }

      List<ReportTopProductModel> result =
          qtyMap.entries.map((e) {
            return ReportTopProductModel(
              name: e.key,
              totalQty: e.value.toString(),
              revenue: (revenueMap[e.key] ?? 0).toInt(),
            );
          }).toList();

      result.sort((a, b) => b.totalQty!.compareTo(a.totalQty.toString()));
      reportTopChart.value = result;
    } catch (e) {
      customMessageOrErrorPrint(message: "Error: $e");
      reportTopChart.value = [];
    }
  }

  Future<List<SellsModel>> fetchRevenueList() async {
    try {
      final today = setFormateDate();
      if (uid == null) return [];
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('sales')
              .where('soldAt', isEqualTo: today)
              .get();
      final List<SellsModel> bills =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return SellsModel.fromJson(data);
          }).toList();

      customMessageOrErrorPrint(
        message: '✅ Total Bills Fetched: ${bills.length}',
      );
      if (bills.isNotEmpty) {
        customMessageOrErrorPrint(
          message:
              'First Bill: ${bills.first.billNo} — ₹${bills.first.finalAmount}',
        );
      }

      return bills;
    } catch (e) {
      showMessage(message: "❌ Error fetching revenue: ${e.toString()}");
      return [];
    }
  }

  Future<void> fetchTopSellingProducts() async {
    if (uid == null) {
      reportTopModel.value = [];
      return;
    }

    String today = setFormateDate();

    Map<String, int> qtyMap = {};
    Map<String, double> revenueMap = {};

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('sales')
              .where('soldAt', isEqualTo: today)
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        List items = data["items"] ?? [];
        for (var item in items) {
          String name = item["name"] ?? "Unknown";
          int qty = (item["quantity"] ?? 1).toInt();
          double finalPrice = (item["finalPrice"] ?? 0).toDouble();
          qtyMap[name] = (qtyMap[name] ?? 0) + qty;
          revenueMap[name] = (revenueMap[name] ?? 0) + finalPrice;
        }
      }

      List<ReportTopProductModel> result =
          qtyMap.entries.map((e) {
            return ReportTopProductModel(
              name: e.key,
              totalQty: e.value.toString(),
              revenue: (revenueMap[e.key] ?? 0).toInt(),
            );
          }).toList();

      result.sort(
        (a, b) => int.parse(b.totalQty!).compareTo(int.parse(a.totalQty!)),
      );

      reportTopModel.value = result;
    } catch (e) {
      reportTopModel.value = [];
    }
  }

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
      reportDownloadGroupValue.value = (-1);
      reportLabels.value = '';
      Get.back();
      showMessage(
        seconds: 5,
        message: 'Report Download Successfully',
        isActionRequired: true,
        onPressed: () {
          OpenFile.open(file);
        },
      );
    } catch (e) {
      customMessageOrErrorPrint(message: e);
      Get.back();
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
    excel.rename("Sheet1", fileName);
    Sheet sheet = excel[fileName];

    sheet.appendRow([TextCellValue('Report Type'), TextCellValue(fileName)]);
    sheet.appendRow([
      TextCellValue('Shop Name'),
      TextCellValue(user.name ?? ''),
    ]);
    sheet.appendRow([TextCellValue('From Date'), TextCellValue(date)]);
    sheet.appendRow([TextCellValue('To Date'), TextCellValue(date2)]);

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // ⭐⭐ Correct Loop ⭐⭐
    for (var element in dataList) {
      final row = mapper(element); // MUST BE A SINGLE ITEM
      sheet.appendRow(row.map((v) => TextCellValue(v)).toList());
    }

    Uint8List excelBytes = Uint8List.fromList(excel.encode()!);
    String savedPath = await saveToDownloads(excelBytes, fileName);
    return savedPath;
  }

  Future<String> saveToDownloads(Uint8List bytes, String fileName) async {
    int sdk = await getAndroidVersion();
    if (sdk >= 30) {
      final downloads = Directory("/storage/emulated/0/Download");
      String filePath =
          "${downloads.path}/$fileName _ Report_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      File file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      return filePath;
    }
    var status = await Permission.storage.request();
    if (!status.isGranted) throw "Storage permission denied";
    final downloads = Directory("/storage/emulated/0/Download");
    String filePath =
        "${downloads.path}/report_${DateTime.now().millisecondsSinceEpoch}.xlsx";
    File file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }

  Future<List<dynamic>> fetchProductReport({
    required String label,
    required String reportType,
  }) async {
    dynamic data;
    (String, String) todaydate = getDateRange(
      label: label,
      customEndDate: '',
      customStartDate: '',
    );
    String collectionName = getCollectionAsPerReportType(reportType);
    if (reportType == 'Product Stock In') {
      data =
          data =
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .collection(collectionName)
                  .where("createdDate", isGreaterThanOrEqualTo: todaydate.$1)
                  .where("createdDate", isLessThanOrEqualTo: todaydate.$2)
                  .get();
    } else {
      data =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .collection(collectionName)
              .where("soldAt", isGreaterThanOrEqualTo: todaydate.$1)
              .where("soldAt", isLessThanOrEqualTo: todaydate.$2)
              .get();
    }

    return data.docs.map((e) => e.data()).toList();
  }

  String getCollectionAsPerReportType(String reportType) {
    String reportCollectionName = '';
    switch (reportType) {
      case 'Product Stock In':
        reportCollectionName = 'products';
        break;
      case 'Selling with Payment':
        reportCollectionName = 'sales';
        break;
      case 'Product Stock Out':
        reportCollectionName = 'sales';
        break;
      case 'Credit Amount':
        reportCollectionName = 'customers';
        break;
      default:
        reportCollectionName = 'products';
    }
    return reportCollectionName;
  }

  (String, String) getDateRange({
    required String label,
    required String customStartDate,
    required String customEndDate,
  }) {
    final now = DateTime.now();
    DateFormat df = DateFormat("dd-MM-yyyy");
    late String startDate;
    late String endDate;
    switch (label) {
      case 'Today':
        startDate = df.format(now);
        endDate = df.format(now);
        break;
      case 'Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        startDate = df.format(weekStart);
        endDate = df.format(now);
        break;
      case 'Month':
        final monthStart = DateTime(now.year, now.month, 1);
        startDate = df.format(monthStart);
        endDate = df.format(now);
        break;
      case 'Custom':
        startDate = customStartDate;
        endDate = customEndDate;
        break;
      default:
        startDate = df.format(now);
        endDate = df.format(now);
    }

    return (startDate, endDate);
  }

  // ------------------ PRODUCT STOCK IN ------------------
  List<String> productStockInMapper(dynamic json) {
    return [
      json["name"] ?? "",
      json["category"] ?? "",
      json["animalType"] ?? "",
      json["weight"] ?? "",
      (json["quantity"] ?? 0).toString(),
      json["createdDate"] ?? "",
      json["createdTime"] ?? "",
    ];
  }

  // ------------------ PRODUCT STOCK OUT ------------------
  List<String> productStockOutMapper(dynamic json) {
    final item = SellItem.fromJson(json);
    return [
      item.name ?? "",
      item.category ?? "",
      item.animalType ?? "",
      item.weight ?? "",
      (item.quantity ?? 0).toString(),
      json["soldAt"] ?? "",
      json["time"] ?? "",
    ];
  }

  // ------------------ SELL WITH PAYMENT ------------------
  List<String> sellWithPaymentMapper(dynamic json) {
    final s = SellsModel.fromJson(json);
    final i = s.items!.first;

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
      (i.originalPrice ?? 0).toString(),
      (i.originalDiscount ?? 0).toString(),
      (i.discount ?? 0).toString(),
      (i.finalPrice ?? 0).toString(),
      s.payment?.type ?? "",
      (s.payment?.cash ?? 0).toString(),
      (s.payment?.upi ?? 0).toString(),
      (s.payment?.card ?? 0).toString(),
      (s.payment?.credit ?? 0).toString(),
      s.soldAt ?? "",
      s.time ?? "",
    ];
  }

  // ------------------ CREDIT AMOUNT ------------------
  List<String> creditAmountMapper(dynamic json) {
    final s = SellsModel.fromJson(json);
    final i = s.items!.first;

    return [
      i.name ?? "",

      i.category ?? "",
      i.animalType ?? "",
      i.weight ?? "",
      (i.quantity ?? 0).toString(),
      (s.totalAmount ?? 0).toString(),
      (s.payment?.credit ?? 0).toString(),
      s.soldAt ?? "",
      s.time ?? "",
    ];
  }

  (
    String reportType,
    List<String> headers,
    List<String> Function(dynamic) mapper,
  )
  getLabelValue({required int reportLabelIndex}) {
    if (reportLabelIndex == 0) {
      return (
        "Product Stock In",
        [
          "Product Name",
          "Category",
          "Animal Type",
          "Weight",
          "Quantity",
          "Date",
          "Time",
        ],
        productStockInMapper,
      );
    }

    if (reportLabelIndex == 1) {
      return (
        "Product Stock Out",
        [
          "Product Name",
          "Category",
          "Animal Type",
          "Weight",
          "Quantity",
          "Date",
          "Time",
        ],
        productStockOutMapper,
      );
    }

    if (reportLabelIndex == 2) {
      return (
        "Sell with Payment",
        [
          "Bill No",
          "Product Name",
          "Barcode",
          "Category",
          "Animal Type",
          "Quantity",
          "Weight",
          "Flavour",
          "Expiry",
          "Selling Price",
          "Original Discount %",
          "Discount %",
          "Final Price",
          "Payment Type",
          "Cash",
          "UPI",
          "Card",
          "Credit",
          "Sold Date",
          "Time",
        ],
        sellWithPaymentMapper,
      );
    }

    return (
      "Credit Amount",
      [
        "Customer Name",
        "Product Name",
        "Category",
        "Animal Type",
        "Weight",
        "Quantity",
        "Product Amount",
        "Credit Amount",
        "Date",
        "Time",
      ],
      creditAmountMapper,
    );
  }
}
