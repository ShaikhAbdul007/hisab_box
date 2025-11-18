import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var selectedTab = 0.obs;

  // Period: Today, Week, Month
  var selectedPeriod = 'Today'.obs;

  // Loading
  var isLoading = false.obs;

  // Data
  var overviewData = {}.obs; // totalRevenue, totalSales, totalInventory
  var salesData = [].obs; // List of sales
  var inventoryData = [].obs; // List of inventory items

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TabController? tabController;

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
    fetchData();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    fetchData();
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;

    try {
      if (selectedTab.value == 0) {
        // Overview metrics
        var salesSnapshot =
            await _firestore
                .collection('sales')
                .where('period', isEqualTo: selectedPeriod.value)
                .get();
        var inventorySnapshot =
            await _firestore
                .collection('inventory')
                .where('period', isEqualTo: selectedPeriod.value)
                .get();

        double totalRevenue = 0;
        salesSnapshot.docs.forEach((doc) {
          totalRevenue += (doc['totalAmount'] ?? 0);
        });

        overviewData.value = {
          'totalRevenue': totalRevenue,
          'totalSales': salesSnapshot.docs.length,
          'totalInventory': inventorySnapshot.docs.length,
        };
      } else if (selectedTab.value == 1) {
        // Sales list
        var salesSnapshot =
            await _firestore
                .collection('sales')
                .where('period', isEqualTo: selectedPeriod.value)
                .get();
        salesData.value =
            salesSnapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
      } else if (selectedTab.value == 2) {
        // Inventory list
        var inventorySnapshot =
            await _firestore
                .collection('inventory')
                .where('period', isEqualTo: selectedPeriod.value)
                .get();
        inventoryData.value =
            inventorySnapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
      }
    } catch (e) {
      print('Firestore fetch error: $e');
    }

    isLoading.value = false;
  }
}
