import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/reports/model/report_top_product_model.dart';
import '../../../helper/helper.dart';
import '../../revenue/model/revenue_model.dart';

class ReportController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  var selectedTab = 0.obs;
  RxDouble totalRevenue = 0.0.obs;
  RxDouble totalProfit = 0.0.obs;
  RxDouble totalCash = 0.0.obs;
  RxDouble totalUpi = 0.0.obs;
  RxDouble totalCard = 0.0.obs;
  RxDouble totalCredit = 0.0.obs;
  RxDouble totalRoundOff = 0.0.obs;
  TabController? tabController;
  RxList<ReportTopProductModel> reportTopModel = <ReportTopProductModel>[].obs;
  RxList<ReportTopProductModel> reportTopChart = <ReportTopProductModel>[].obs;
  var sellsList = <SellsModel>[].obs;
  List<String> daysOtionLabel = ['Today', 'Week', 'Month', 'Custom'];

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

    String today = setFormateDate(); // example: 22-11-2025

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
      print("Payment Summary Error: $e");
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
    if (uid == null) {
      totalProfit.value = 0.0;
      totalRevenue.value = 0.0;
    }
    try {
      // -------- FETCH SALE DATA --------
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('sales')
              .where('soldAt', isEqualTo: today)
              .get();

      if (snapshot.docs.isEmpty) {
        totalProfit.value = 0.0;
        totalRevenue.value = 0.0;
      }
      for (var doc in snapshot.docs) {
        final data = doc.data();
        double finalAmount = (data['finalAmount'] ?? 0).toDouble();
        totalRevenue.value += finalAmount;
        List items = data["items"] ?? [];
        for (var item in items) {
          double selling = (item["finalPrice"] ?? 0).toDouble();
          double cost = (item["purchasePrice"] ?? 0).toDouble();
          int qty = (item["quantity"] ?? 1).toInt();
          totalProfit.value += (selling - cost) * qty;
        }
      }
    } catch (e) {
      print("Error: $e");
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
      print("Error: $e");
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

      print('✅ Total Bills Fetched: ${bills.length}');
      if (bills.isNotEmpty) {
        print(
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
    if (uid == null) reportTopModel.value = [];

    // TODAY DATE
    String today = setFormateDate();

    Map<String, int> qtyMap = {}; // name → totalQty
    Map<String, double> revenueMap = {};

    try {
      // FETCH TODAY SALES
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
      reportTopModel.value = result;
    } catch (e) {
      print("Error: $e");
      reportTopModel.value = [];
    }
  }
}
