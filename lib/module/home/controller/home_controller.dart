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
import '../../../helper/set_format_date.dart';
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

    // Direct Supabase se load karo, cache nahi
    await _loadFromSupabase();
    await getDashBoardList();

    isListLoading.value = false;
  }

  // ================= SUPABASE DATA LOADING =================

  Future<void> _loadFromSupabase() async {
    await Future.wait([
      getTotalRevenue(),
      getTotalStock(),
      getOutOfStock(),
      getTotalLooseStock(),
    ]);
    sellsList.value = await fetchRevenueList();
  }

  // ================= DASHBOARD FUNCTIONS =================

  Future<void> getTotalRevenue() async {
    if (userId == null) return;

    try {
      // Date filter ko ISO format mein set karo
      final DateTime now = DateTime.now();
      final String startOfToday =
          DateTime(now.year, now.month, now.day).toIso8601String();
      final String endOfToday =
          DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      final response = await SupabaseConfig.from('sales')
          .select('total_amount')
          .eq('user_id', userId!)
          .gte('created_at', startOfToday)
          .lte('created_at', endOfToday);

      double total = 0;
      if (response != null) {
        for (var sale in response) {
          total += (sale['total_amount'] ?? 0).toDouble();
        }
      }

      totalBusRevenue.value = total;
      print("💰 Today's Revenue: $total"); // Debugging ke liye
    } catch (e) {
      print("🚨 Revenue Error: $e");
    }
  }

  Future<void> getTotalStock() async {
    if (userId == null) return;

    try {
      // Shop products - simple count by getting length
      final shopResponse = await SupabaseConfig.from('product_stock')
          .select('id')
          .eq('user_id', userId!)
          .eq('is_active', true)
          .eq('location', 'shop');

      // Godown products - simple count by getting length
      final godownResponse = await SupabaseConfig.from('product_stock')
          .select('id')
          .eq('user_id', userId!)
          .eq('is_active', true)
          .eq('location', 'godown');

      final shopCount = (shopResponse as List).length;
      final godownCount = (godownResponse as List).length;

      stock.value = shopCount + godownCount;
    } catch (e) {
      // Total Stock Error: $e
      stock.value = 0;
    }
  }

  Future<void> getOutOfStock() async {
    if (userId == null) return;

    try {
      // Out of stock ka matlab: is_active ho aur quantity 0 ho
      // select('count') use karna zyada fast hai length nikalne se
      final response = await SupabaseConfig.from('product_stock')
          .select('id')
          .eq('user_id', userId!)
          .eq('is_active', true)
          .eq('quantity', 0);

      if (response != null) {
        outOfStock.value = (response as List).length;
        print("📦 Out of Stock Count: ${outOfStock.value}");
      }
    } catch (e) {
      print("🚨 Out Of Stock Error: $e");
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
      // Loose Stock Error: $e
      looseStock.value = 0;
    }
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
