import 'package:inventory/helper/logger.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/module/product_details/model/go_down_stock_transfer_to_shop_model.dart';
import 'package:inventory/module/revenue/model/revenue_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/local_db/local_db_service.dart';
import '../../../routes/route_name.dart';
import '../model/grid_model.dart';
import 'package:inventory/module/gobal_module/gobal_controller.dart';

class HomeController extends GetxController with CacheManager {
  final globalStore = Get.find<GlobalStore>();

  // ================= DASHBOARD STATE =================
  RxDouble totalBusRevenue = 0.0.obs;
  RxNum stock = RxNum(0);
  RxNum goDownStock = RxNum(0);
  RxNum sellStock = RxNum(0);
  RxNum totalExpense = RxNum(0);
  RxNum looseStock = RxNum(0);
  RxNum outOfStock = RxNum(0);
  RxNum nearExpiryCount = RxNum(0); // 🔥 NEW: Near Expiry Variable

  var productList = <ProductModel>[].obs;
  var sellsList = <SellsModel>[].obs;
  RxList<LooseInvetoryModel> looseInventoryLis = <LooseInvetoryModel>[].obs;

  List<Map<String, dynamic>> chartData = [];
  List<CustomGridModel> lis = [];

  RxBool isListLoading = false.obs;

  // ================= STOCK TRANSFER =================
  RxList<GoDownStockTransferToShopModel> pendingTransfers =
      <GoDownStockTransferToShopModel>[].obs;

  final userId = SupabaseConfig.auth.currentUser?.id;

  // ================= INIT =================
  @override
  void onInit() {
    // 1. Initial Load (Hive + RAM)
    loadDashboard();

    // 2. 🔥 Realtime Workers
    ever(globalStore.cashTotal, (_) => syncFromGlobalStore());
    ever(globalStore.upiTotal, (_) => syncFromGlobalStore());
    ever(globalStore.cardTotal, (_) => syncFromGlobalStore());
    ever(globalStore.creditTotal, (_) => syncFromGlobalStore());

    ever(globalStore.allProducts, (_) => syncStockFromGlobalStore());
    ever(globalStore.allLooseProducts, (_) => syncStockFromGlobalStore());
    ever(globalStore.allSalesList, (_) => syncFromGlobalStore());

    super.onInit();
  }

  // ================= SYNC LOGIC (ZERO SUPABASE CALLS) =================

  void syncFromGlobalStore() {
    totalBusRevenue.value =
        globalStore.cashTotal.value +
        globalStore.upiTotal.value +
        globalStore.cardTotal.value +
        globalStore.creditTotal.value;

    sellsList.assignAll(globalStore.allSalesList);

    getDashBoardList();
    _syncSupabaseToHive();
  }

  void syncStockFromGlobalStore() {
    stock.value = globalStore.allProducts.length;

    outOfStock.value =
        globalStore.allProducts.where((p) => (p.quantity ?? 0) <= 0).length;

    // 🔥 NEAR EXPIRY LOGIC (90 Days)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final ninetyDaysLater = now.add(const Duration(days: 90));

    nearExpiryCount.value =
        globalStore.allProducts.where((p) {
          if (p.expireDate == null || p.expireDate!.isEmpty) return false;
          DateTime? exp = DateTime.tryParse(p.expireDate!);
          if (exp == null) return false;
          return exp.isAfter(today.subtract(const Duration(days: 1))) &&
              exp.isBefore(ninetyDaysLater);
        }).length;

    looseStock.value = globalStore.allLooseProducts.length;

    getDashBoardList();
  }

  // ================= DASHBOARD MAIN =================
  Future<void> loadDashboard() async {
    isListLoading.value = true;
    _loadFromHive();
    syncFromGlobalStore();
    syncStockFromGlobalStore();
    await getDashBoardList();
    isListLoading.value = false;
  }

  // ================= HIVE DATA LOADING =================
  void _loadFromHive() {
    try {
      Map<String, dynamic> stats = LocalService.getDailyReportStats();
      totalBusRevenue.value =
          (double.tryParse(stats['total_sales']?.toString() ?? '0.0') ?? 0.0);

      outOfStock.value = LocalService.getCachedOutOfStockProducts().length;
      stock.value = LocalService.getCachedProducts().length;
      looseStock.value = LocalService.getCachedLooseProducts().length;

      // Hive fallback for expiry
      nearExpiryCount.value = LocalService.getCachedExpiryProducts().length;

      getDashBoardList();
    } catch (e) {
      AppLogger.info(("🚨 Hive Load Error: $e").toString());
    }
  }

  // ================= LEGACY SUPABASE (MAPPED TO GLOBAL) =================

  Future<void> loadFromSupabase() async {
    syncFromGlobalStore();
    syncStockFromGlobalStore();
  }

  void _syncSupabaseToHive() async {
    Map<String, dynamic> stats = LocalService.getDailyReportStats();
    stats['total_sales'] = totalBusRevenue.value;
    await LocalService.saveDailyReportStats(stats);
  }

  Future<void> getTotalRevenue() async {
    syncFromGlobalStore();
  }

  Future<void> getTotalStock() async {
    syncStockFromGlobalStore();
  }

  Future<void> getOutOfStock() async {
    syncStockFromGlobalStore();
  }

  Future<void> getTotalLooseStock() async {
    syncStockFromGlobalStore();
  }

  Future<List<SellsModel>> fetchRevenueList() async {
    return globalStore.allSalesList;
  }

  // ================= DASHBOARD GRID =================
  Future<void> getDashBoardList() async {
    lis = [
      CustomGridModel(
        routeName: AppRouteName.inventroyList,
        label: 'Total Products',
        icon: CupertinoIcons.cube_fill,
        numbers: stock.value.toDouble(),
      ),
      CustomGridModel(
        routeName: AppRouteName.outOfStock,
        label: 'Out Of Stock',
        icon: CupertinoIcons.cube_box,
        numbers: outOfStock.value.toDouble(),
      ),
      CustomGridModel(
        routeName: AppRouteName.revenueView,
        label: 'Today Sales',
        icon: Icons.paid,
        numbers: totalBusRevenue.value,
      ),
      CustomGridModel(
        routeName: AppRouteName.looseSell,
        label: 'Loose Stock',
        icon: CupertinoIcons.info,
        numbers: looseStock.value.toDouble(),
      ),
    ];
  }
}
