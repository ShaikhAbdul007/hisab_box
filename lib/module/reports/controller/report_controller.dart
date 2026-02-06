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
    // Direct Supabase se load karo, cache nahi
    await Future.wait([
      fetchTodaySalesAndProfit(),
      fetchPaymentSummary(),
      fetchTopSellingProducts(),
      fetchTopSellingProductsChart(),
      setSellList(),
    ]);
  }

  Future<void> fetchPaymentSummary() async {
    if (userId == null) {
      totalCash.value = 0.0;
      totalUpi.value = 0.0;
      totalCard.value = 0.0;
      totalCredit.value = 0.0;
      totalRoundOff.value = 0.0;
      return;
    }

    String today = setFormateDate();

    try {
      final response = await SupabaseConfig.from('sales')
          .select('''
            id,
            sale_payments (
              amount,
              payment_mode
            )
          ''')
          .eq('user_id', userId!)
          .gte('created_at', '${today}T00:00:00.000Z')
          .lt('created_at', '${today}T23:59:59.999Z');

      totalCash.value = 0.0;
      totalUpi.value = 0.0;
      totalCard.value = 0.0;
      totalCredit.value = 0.0;
      totalRoundOff.value = 0.0;

      for (var sale in response) {
        final payments = sale['sale_payments'] as List?;
        if (payments != null) {
          for (var payment in payments) {
            final mode =
                payment['payment_mode']?.toString().toLowerCase() ?? '';
            final amount = (payment['amount'] ?? 0).toDouble();

            switch (mode) {
              case 'cash':
                totalCash.value += amount;
                break;
              case 'upi':
                totalUpi.value += amount;
                break;
              case 'card':
                totalCard.value += amount;
                break;
              case 'credit':
                totalCredit.value += amount;
                break;
            }
          }
        }
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

  double calculateItemProfit(Map<String, dynamic> item) {
    final int qty = (item['quantity'] ?? 1).toInt();
    final double purchasePrice = (item['purchasePrice'] ?? 0).toDouble();

    // total selling (prefer finalPrice → originalPrice → sellingPrice)
    final double totalSelling =
        (item['finalPrice'] ??
                item['originalPrice'] ??
                item['sellingPrice'] ??
                0)
            .toDouble();

    final String sellType = (item['sellType'] ?? 'packet').toString();

    if (qty <= 0 || purchasePrice <= 0 || totalSelling <= 0) {
      return 0;
    }

    // 🔥 PACKET (default & backward compatible)
    if (sellType == 'packet') {
      return totalSelling - (purchasePrice * qty);
    }

    // 🔥 LOOSE
    final int totalPieces = (item['totalPieces'] ?? qty).toInt();
    final int soldQty = (item['soldQty'] ?? qty).toInt();

    if (totalPieces <= 0 || soldQty <= 0) return 0;

    final double costPerPiece = purchasePrice / totalPieces;
    final double sellingPerPiece = (item['sellingPrice'] ?? 0).toDouble();

    return (sellingPerPiece - costPerPiece) * soldQty;
  }

  Future<void> fetchTodaySalesAndProfit() async {
    final String today = setFormateDate();

    totalProfit.value = 0.0;
    totalRevenue.value = 0.0;

    if (userId == null) return;

    try {
      // Step 1: Get sales data without product join
      final response = await SupabaseConfig.from('sales')
          .select('''
            id,
            total_amount,
            sale_items (
              qty,
              final_price,
              original_price,
              product_id
            )
          ''')
          .eq('user_id', userId!)
          .gte('created_at', '${today}T00:00:00.000Z')
          .lt('created_at', '${today}T23:59:59.999Z');

      for (final sale in response) {
        // ---------- REVENUE ----------
        totalRevenue.value += (sale['total_amount'] ?? 0).toDouble();

        // ---------- PROFIT ----------
        final List items = sale['sale_items'] ?? [];

        for (final item in items) {
          final int qty = (item['qty'] ?? 1).toInt();
          final double finalPrice = (item['final_price'] ?? 0).toDouble();
          final String? productId = item['product_id'];

          if (productId != null && qty > 0 && finalPrice > 0) {
            // Step 2: Get purchase price from stock_batches separately
            try {
              final batchResponse =
                  await SupabaseConfig.from('stock_batches')
                      .select('purchase_price')
                      .eq('product_id', productId)
                      .eq('user_id', userId!)
                      .limit(1)
                      .maybeSingle();

              final double purchasePrice =
                  (batchResponse?['purchase_price'] ?? 0).toDouble();

              if (purchasePrice > 0) {
                totalProfit.value += finalPrice - (purchasePrice * qty);
              }
            } catch (e) {
              // Skip this item if batch data not found
              continue;
            }
          }
        }
      }
    } catch (e) {
      customMessageOrErrorPrint(message: "Sales & Profit Error: $e");
      totalProfit.value = 0.0;
      totalRevenue.value = 0.0;
    }
  }

  Future<void> fetchTopSellingProductsChart() async {
    if (userId == null) {
      reportTopChart.value = [];
      return;
    }

    String today = setFormateDate();

    Map<String, int> qtyMap = {};
    Map<String, double> revenueMap = {};

    try {
      // Step 1: Get sale items without product join
      final response = await SupabaseConfig.from('sales')
          .select('''
            id,
            sale_items (
              qty,
              final_price,
              product_id
            )
          ''')
          .eq('user_id', userId!)
          .gte('created_at', '${today}T00:00:00.000Z')
          .lt('created_at', '${today}T23:59:59.999Z');

      // Step 2: Get product names separately
      Set<String> productIds = {};
      for (var sale in response) {
        final List items = sale["sale_items"] ?? [];
        for (var item in items) {
          final productId = item['product_id'];
          if (productId != null) {
            productIds.add(productId);
          }
        }
      }

      // Step 3: Get product names in batch
      Map<String, String> productNames = {};
      if (productIds.isNotEmpty) {
        final productResponse = await SupabaseConfig.from(
          'products',
        ).select('id, name').inFilter('id', productIds.toList());

        for (var product in productResponse) {
          productNames[product['id']] = product['name'] ?? 'Unknown';
        }
      }

      // Step 4: Process the data
      for (var sale in response) {
        final List items = sale["sale_items"] ?? [];

        for (var item in items) {
          final productId = item['product_id'];
          String name = productNames[productId] ?? "Unknown";
          int qty = (item["qty"] ?? 1).toInt();
          double price = (item["final_price"] ?? 0).toDouble();

          qtyMap[name] = (qtyMap[name] ?? 0) + qty;
          revenueMap[name] = (revenueMap[name] ?? 0) + price;
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
      customMessageOrErrorPrint(message: "Top Chart Error: $e");
      reportTopChart.value = [];
    }
  }

  Future<List<SellsModel>> fetchRevenueList() async {
    try {
      final today = setFormateDate();
      if (userId == null) return [];

      final response = await SupabaseConfig.from('sales')
          .select('''
            id,
            total_amount,
            created_at,
            customer_id,
            customers (name, mobile_number),
            sale_items (
              qty,
              final_price,
              original_price,
              discount_amount,
              product_id
            ),
            sale_payments (
              amount,
              payment_mode,
              reference_no
            )
          ''')
          .eq('user_id', userId!)
          .gte('created_at', '${today}T00:00:00.000Z')
          .lt('created_at', '${today}T23:59:59.999Z')
          .order('created_at', ascending: false);

      final List<SellsModel> bills =
          response.map((data) {
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
    if (userId == null) {
      reportTopModel.value = [];
      return;
    }

    String today = setFormateDate();

    Map<String, int> qtyMap = {};
    Map<String, double> revenueMap = {};

    try {
      // Step 1: Get sale items without product join
      final response = await SupabaseConfig.from('sales')
          .select('''
            id,
            sale_items (
              qty,
              final_price,
              product_id
            )
          ''')
          .eq('user_id', userId!)
          .gte('created_at', '${today}T00:00:00.000Z')
          .lt('created_at', '${today}T23:59:59.999Z');

      // Step 2: Get product names separately
      Set<String> productIds = {};
      for (var sale in response) {
        final List items = sale["sale_items"] ?? [];
        for (var item in items) {
          final productId = item['product_id'];
          if (productId != null) {
            productIds.add(productId);
          }
        }
      }

      // Step 3: Get product names in batch
      Map<String, String> productNames = {};
      if (productIds.isNotEmpty) {
        final productResponse = await SupabaseConfig.from(
          'products',
        ).select('id, name').inFilter('id', productIds.toList());

        for (var product in productResponse) {
          productNames[product['id']] = product['name'] ?? 'Unknown';
        }
      }

      // Step 4: Process the data
      for (var sale in response) {
        final List items = sale["sale_items"] ?? [];
        for (var item in items) {
          final productId = item['product_id'];
          String name = productNames[productId] ?? "Unknown";
          int qty = (item["qty"] ?? 1).toInt();
          double finalPrice = (item["final_price"] ?? 0).toDouble();

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
      customMessageOrErrorPrint(message: "Top Products Error: $e");
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
    if (userId == null) return [];

    (String, String) todaydate = getDateRange(
      label: label,
      customEndDate: '',
      customStartDate: '',
    );

    try {
      if (reportType == 'Product Stock In') {
        // Product stock in from stock_batches table
        final response = await SupabaseConfig.from('stock_batches')
            .select('''
              id,
              quantity,
              purchase_date,
              created_at,
              products (
                name,
                categories:category (name),
                animals:animal_type (name),
                weight
              )
            ''')
            .eq('user_id', userId!)
            .gte('purchase_date', _convertDateFormat(todaydate.$1))
            .lte('purchase_date', _convertDateFormat(todaydate.$2));

        return response
            .map(
              (e) => {
                'name': e['products']?['name'] ?? '',
                'category': e['products']?['categories']?['name'] ?? '',
                'animalType': e['products']?['animals']?['name'] ?? '',
                'weight': e['products']?['weight'] ?? '',
                'quantity': e['quantity'] ?? 0,
                'createdDate': e['purchase_date'] ?? '',
                'createdTime': e['created_at'] ?? '',
              },
            )
            .toList();
      } else {
        // Sales related reports
        final response = await SupabaseConfig.from('sales')
            .select('''
              id,
              total_amount,
              created_at,
              customers (name),
              sale_items (
                qty,
                final_price,
                original_price,
                discount_amount,
                product_id
              ),
              sale_payments (
                amount,
                payment_mode,
                reference_no
              )
            ''')
            .eq('user_id', userId!)
            .gte(
              'created_at',
              '${_convertDateFormat(todaydate.$1)}T00:00:00.000Z',
            )
            .lte(
              'created_at',
              '${_convertDateFormat(todaydate.$2)}T23:59:59.999Z',
            );

        return response;
      }
    } catch (e) {
      customMessageOrErrorPrint(message: "Product Report Error: $e");
      return [];
    }
  }

  String _convertDateFormat(String ddMMyyyy) {
    try {
      final parts = ddMMyyyy.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}'; // yyyy-MM-dd
      }
    } catch (e) {
      customMessageOrErrorPrint(message: "Date conversion error: $e");
    }
    return ddMMyyyy;
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
    return [
      json['name'] ?? "",
      json['category'] ?? "",
      json['animalType'] ?? "",
      json['weight'] ?? "",
      json['quantity'] ?? 0,
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
