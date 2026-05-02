import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/home/model/dashboard_model.dart';
import 'package:inventory/module/home/repo/home_repo.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/module/product_details/model/go_down_stock_transfer_to_shop_model.dart';
import 'package:inventory/module/sell/model/sell_model.dart';
import '../../../routes/route_name.dart';
import '../model/grid_model.dart';

class HomeController extends GetxController with CacheManager {
  HomeRepo homeRepo = HomeRepo();

  // ================= DASHBOARD STATE =================
  RxNum totalBusRevenue = RxNum(0);
  RxNum stock = RxNum(0);
  RxNum goDownStock = RxNum(0);
  RxNum sellStock = RxNum(0);
  RxNum totalExpense = RxNum(0);
  RxNum looseStock = RxNum(0);
  RxNum outOfStock = RxNum(0);
  RxNum nearExpiryCount = RxNum(0); // 🔥 NEW: Near Expiry Variable

  var productList = <SellItemData>[].obs;
  RxList<RecentActivitiesData> sellsList = <RecentActivitiesData>[].obs;
  RxList<LooseInvetoryModel> looseInventoryLis = <LooseInvetoryModel>[].obs;

  List<Map<String, dynamic>> chartData = [];
  List<CustomGridModel> lis = [];
  RxString shopType = ''.obs;
  RxBool isListLoading = false.obs;

  // ================= STOCK TRANSFER =================
  RxList<GoDownStockTransferToShopModel> pendingTransfers =
      <GoDownStockTransferToShopModel>[].obs;

  // ================= INIT =================
  @override
  void onInit() {
    setShopType();
    loadDashboard();
    super.onInit();
  }

  void setShopType() {
    var user = retrieveUserDetail();
    shopType.value = user.data?.shopType ?? 'Pet Shop';
  }

  // ================= SYNC LOGIC (ZERO SUPABASE CALLS) =================
  void loadDashboard() async {
    isListLoading.value = true;
    try {
      final response = await homeRepo.getDashBoardData();
      if (response.success == success) {
        sellsList.value =
            response.data?.recentActivities?.recentActivitiesData ?? [];
        stock.value = response.data?.stats?.totalProducts ?? 0.0;
        totalBusRevenue.value = response.data?.stats?.todaySales ?? 0.0;
        outOfStock.value = response.data?.stats?.outOfStock ?? 0.0;
        looseStock.value = response.data?.stats?.looseStock ?? 0.0;
      } else if (response.success == failed) {
        showSnackBar(error: response.message ?? '');
      } else {
        showSnackBar(error: response.message ?? '');
      }
    } catch (e) {
      AppLogger.info((e).toString());
      showSnackBar(error: e.toString());
    } finally {
      getDashBoardList();
      isListLoading.value = false;
    }
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
        numbers: totalBusRevenue.value.toDouble(),
      ),
      CustomGridModel(
        routeName: AppRouteName.looseSell,
        label:
            shopType.value == 'Clothing Shop'
                ? 'Good Return(GR)'
                : 'Loose Stock',
        icon: CupertinoIcons.info,
        numbers: looseStock.value.toDouble(),
      ),
    ];
  }
}
