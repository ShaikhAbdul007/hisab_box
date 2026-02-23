import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/module/product_details/model/go_down_stock_transfer_to_shop_model.dart';
import 'package:inventory/module/revenue/model/revenue_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Mixin
import 'package:inventory/helper/set_format_date.dart'; // 🔥 Date Helper
import '../../../routes/route_name.dart';
import '../model/grid_model.dart';

class HomeController extends GetxController with CacheManager {
  // ================= DASHBOARD STATE =================

  RxDouble totalBusRevenue = 0.0.obs;
  RxNum stock = RxNum(0);
  RxNum goDownStock = RxNum(0);
  RxNum sellStock = RxNum(0);
  RxNum totalExpense = RxNum(0);
  RxNum looseStock = RxNum(0);
  RxNum outOfStock = RxNum(0);

  var productList = <ProductModel>[].obs;
  var sellsList = <SellsModel>[].obs;
  RxList<LooseInvetoryModel> looseInventoryLis = <LooseInvetoryModel>[].obs;

  List<Map<String, dynamic>> chartData = [];
  List<CustomGridModel> lis = [];

  RxBool isListLoading = false.obs;

  // ================= STOCK TRANSFER =================

  RxList<GoDownStockTransferToShopModel> pendingTransfers =
      <GoDownStockTransferToShopModel>[].obs;

  // ================= USER ID =================

  final userId = SupabaseConfig.auth.currentUser?.id;

  // ================= INIT =================

  @override
  void onInit() {
    loadDashboard();
    super.onInit();
  }

  // ================= DASHBOARD MAIN =================

  Future<void> loadDashboard() async {
    isListLoading.value = true;

    // 1️⃣ [NEW] Pehle Hive se load karo taaki UI zero na dikhe
    _loadFromHive();

    // 2️⃣ Background mein Supabase se load karo
    await _loadFromSupabase();

    // 3️⃣ Final Grid refresh
    await getDashBoardList();

    isListLoading.value = false;
  }

  // ================= [NEW] HIVE DATA LOADING =================

  void _loadFromHive() {
    try {
      // Get Revenue from stats
      Map<String, dynamic> stats = LocalService.getDailyReportStats();
      totalBusRevenue.value =
          (double.tryParse(stats['total_sales']?.toString() ?? '0.0') ?? 0.0);

      // Get Stock counts from cached lists
      outOfStock.value = LocalService.getCachedOutOfStockProducts().length;
      stock.value = LocalService.getCachedProducts().length;
      looseStock.value = LocalService.getCachedLooseProducts().length;

      // Get Recent Sales list
      final String todayDate = setFormateDate('yyyy-MM-dd');
      var cachedSales = LocalService.getTodaySales(todayDate);

      sellsList.value =
          cachedSales
              .map(
                (s) => SellsModel(
                  billNo: int.parse(s.billNo),
                  finalAmount: s.amountAfterDiscount,
                  totalAmount: s.amount,
                  soldAt: s.soldAt,
                  time: s.time,
                  itemsCount: s.quantity,
                  items: [],
                  payment: PaymentModel(
                    totalAmount: s.amountAfterDiscount,
                    type: 'Sale',
                    cash: 0.0,
                    upi: 0.0,
                    card: 0.0,
                    credit: 0.0,
                    roundOffAmount: 0.0,
                    isRoundOff: false,
                  ),
                ),
              )
              .toList();

      getDashBoardList();
      update();
    } catch (e) {
      print("🚨 Hive Load Error: $e");
    }
  }

  // ================= SUPABASE DATA LOADING =================

  Future<void> _loadFromSupabase() async {
    await Future.wait([
      getTotalRevenue(),
      getTotalStock(),
      getOutOfStock(),
      getTotalLooseStock(),
    ]);

    // [NEW] Sync Cloud Revenue to Local Stats
    _syncSupabaseToHive();

    sellsList.value = await fetchRevenueList();
  }

  void _syncSupabaseToHive() async {
    Map<String, dynamic> stats = LocalService.getDailyReportStats();
    stats['total_sales'] = totalBusRevenue.value;
    await LocalService.saveDailyReportStats(stats);
  }

  // ================= DASHBOARD FUNCTIONS =================

  Future<void> getTotalRevenue() async {
    if (userId == null) return;
    try {
      final DateTime now = DateTime.now();
      final DateTime localStart = DateTime(
        now.year,
        now.month,
        now.day,
        0,
        0,
        0,
      );
      final DateTime localEnd = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      );

      final String startUtc = localStart.toUtc().toIso8601String();
      final String endUtc = localEnd.toUtc().toIso8601String();

      final response = await SupabaseConfig.from('sales')
          .select('total_amount')
          .eq('user_id', userId!)
          .gte('created_at', startUtc)
          .lte('created_at', endUtc);
      double total = 0;
      final List<dynamic> data = response as List;
      for (var sale in data) {
        total += (sale['total_amount'] ?? 0).toDouble();
      }
      totalBusRevenue.value = total;
      print("💰 Today's Revenue (UTC Corrected): $total");
    } catch (e) {
      print("🚨 Revenue Error: $e");
      totalBusRevenue.value = 0.0;
    }
  }

  Future<void> getTotalStock() async {
    if (userId == null) return;
    try {
      final shopResponse = await SupabaseConfig.from('product_stock')
          .select('id')
          .eq('user_id', userId!)
          .eq('is_active', true)
          .eq('location', 'shop');

      final godownResponse = await SupabaseConfig.from('product_stock')
          .select('id')
          .eq('user_id', userId!)
          .eq('is_active', true)
          .eq('location', 'godown');

      stock.value =
          (shopResponse as List).length + (godownResponse as List).length;
    } catch (e) {
      stock.value = 0;
    }
  }

  Future<void> getOutOfStock() async {
    if (userId == null) return;
    try {
      final response = await SupabaseConfig.from('product_stock')
          .select('id')
          .eq('user_id', userId!)
          .eq('is_active', true)
          .eq('quantity', 0);
      outOfStock.value = (response as List).length;
    } catch (e) {
      outOfStock.value = 0;
    }
  }

  Future<void> getTotalLooseStock() async {
    if (userId == null) return;
    try {
      final response = await SupabaseConfig.from(
        'loose_stocks',
      ).select('id').eq('user_id', userId!);
      looseStock.value = (response as List).length;
    } catch (e) {
      looseStock.value = 0;
    }
  }

  Future<List<SellsModel>> fetchRevenueList() async {
    if (userId == null) return [];
    final DateTime now = DateTime.now();
    final DateTime localStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final DateTime localEnd = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    );

    final String startUtc = localStart.toUtc().toIso8601String();
    final String endUtc = localEnd.toUtc().toIso8601String();

    try {
      final response = await SupabaseConfig.from('sales')
          .select('''
        id, bill_no, total_amount, created_at, customer_id,
        customers (name, mobile_number),
        sale_items (
          qty, final_price, original_price, discount_amount, product_id,
          applied_discount_percent, stock_type, location,
          products ( name )
        ),
        sale_payments ( amount, payment_mode, reference_no )
      ''')
          .eq('user_id', userId!)
          .gte('created_at', startUtc)
          .lte('created_at', endUtc)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List;
      return data.map((sale) {
        final List<dynamic> dbItems = sale['sale_items'] ?? [];
        final List<dynamic> dbPayments = sale['sale_payments'] ?? [];

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

        double cash = 0, upi = 0, card = 0, credit = 0, roundOffAmount = 0;
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
          } else if (mode == 'roundoffAmount') {
            roundOffAmount += amt;
          }
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
            roundOffAmount: roundOffAmount,
            cash: cash,
            upi: upi,
            card: card,
            credit: credit,
            totalAmount: (sale['total_amount'] ?? 0).toDouble(),
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
    ]; // 🔥 Ensure UI Rebuilds
  }
}
