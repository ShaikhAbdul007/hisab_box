import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/helper/shop_type.dart';
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
import '../../../routes/routes.dart';
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
  RxNum nearExpiryCount = RxNum(0);
  RxNum totalGrns = RxNum(0);
  RxNum grcount = RxNum(0); // 🔥 NEW: Near Expiry Variable

  var productList = <SellItemData>[].obs;
  RxList<RecentActivitiesData> sellsList = <RecentActivitiesData>[].obs;
  RxList<LooseInvetoryModel> looseInventoryLis = <LooseInvetoryModel>[].obs;
  RxBool isLoadingMoreActivities = false.obs;
  int _activitiesPage = 1;
  int _activitiesTotalPages = 1;
  bool get activitiesHasMore => _activitiesPage < _activitiesTotalPages;

  List<Map<String, dynamic>> chartData = [];
  RxList<CustomGridModel> lis = <CustomGridModel>[].obs;
  RxString shopType = ''.obs;
  RxBool isListLoading = false.obs;

  ShopType get shopTypeEnum => ShopType.fromString(shopType.value);

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
        _activitiesPage = 1;
        sellsList.value =
            response.data?.recentActivities?.recentActivitiesData ?? [];
        _activitiesTotalPages =
            response.data?.recentActivities?.pagination?.totalPages ?? 1;
        stock.value = response.data?.stats?.totalProducts ?? 0.0;
        totalBusRevenue.value = response.data?.stats?.todaySales ?? 0.0;
        outOfStock.value = response.data?.stats?.outOfStock ?? 0.0;
        looseStock.value = response.data?.stats?.looseStock ?? 0.0;
        nearExpiryCount.value = response.data?.stats?.nearExpiry ?? 0.0;
        totalGrns.value = response.data?.stats?.totalGrns ?? 0.0;
        grcount.value = response.data?.stats?.totalGrns ?? 0.0;
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

  // ================= RECENT ACTIVITIES PAGINATION =================
  Future<void> loadMoreActivities() async {
    if (!activitiesHasMore || isLoadingMoreActivities.value) return;
    _activitiesPage++;
    isLoadingMoreActivities.value = true;
    try {
      final response = await homeRepo.getDashBoardData(page: _activitiesPage);
      if (response.success == success) {
        sellsList.addAll(
          response.data?.recentActivities?.recentActivitiesData ?? [],
        );
        _activitiesTotalPages =
            response.data?.recentActivities?.pagination?.totalPages ??
            _activitiesTotalPages;
      } else {
        _activitiesPage--;
      }
    } catch (e) {
      _activitiesPage--;
      AppLogger.info((e).toString());
    } finally {
      isLoadingMoreActivities.value = false;
    }
  }

  /// Navigate based on activity type
  void navigateFromActivity(RecentActivitiesData activity) {
    switch (activity.type) {
      case 'sale':
        AppRoutes.navigateRoutes(
          routeName: AppRouteName.revenueDetailView,
          data: activity, // saleId available via activity.id
        );
        break;
      case 'grn':
        AppRoutes.navigateRoutes(routeName: AppRouteName.notificationView);
        break;
      case 'product':
        AppRoutes.navigateRoutes(routeName: AppRouteName.inventroyList);
        break;
      default:
        break;
    }
  }

  // ================= DASHBOARD GRID =================
  Future<void> getDashBoardList() async {
    lis.assignAll([
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
        label: shopTypeEnum.config.looseStockGridLabel,
        icon: CupertinoIcons.info,
        numbers:
            shopTypeEnum.config.supportsGRStock
                ? grcount.value.toDouble()
                : looseStock.value.toDouble(),
      ),
    ]);
  }
}
