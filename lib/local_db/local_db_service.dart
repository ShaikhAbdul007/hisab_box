import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/discount/model/discount_model.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/module/product_details/model/go_down_stock_transfer_to_shop_model.dart';
import 'package:inventory/module/reports/model/report_top_product_model.dart';
import 'package:inventory/module/revenue/model/revenue_model.dart';
import 'package:inventory/module/sell/model/sell_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

mixin class LocalService {
  static const String _boxName = 'inventoryBox';
  static const String _productKey = 'cached_products';
  static const String _cachedTopProductKey = 'cached_top_products';
  static const String _productlooseKey = 'cached_loose_products';
  static const String _productExpiryKey = 'cached_expiry_products';
  static const String _productOutofStockKey = 'cached_out_of_stock';
  static const String _categoriesKey = 'cached_categories';
  static const String _animalCategoriesKey = 'cached_animal_types';
  static const String _salesKey = 'daily_sales_';
  static const String _notifKey = 'pending_stock_transfers';
  static const String _dailyReportStatsKey = 'daily_report_stats';
  static late Box _box;

  static Future<void> initHive() async {
    // 1. Flutter ke liye init (Ab ye error nahi dega)
    await Hive.initFlutter();

    // 2. Box open karke variable mein set karein
    _box = await Hive.openBox(_boxName);
    print("✅ Hive Box Opened Successfully");
  }

  // Sales ke liye key

  // 1. Sales Save Karna
  static Future<void> saveTodaySales(String date, List<SaleModel> sales) async {
    List<Map<String, dynamic>> rawData = sales.map((s) => s.toJson()).toList();
    await _box.put('$_salesKey$date', rawData);
  }

  // 2. Sales Get Karna
  static List<SaleModel> getTodaySales(String date) {
    List? rawData = _box.get('$_salesKey$date');
    if (rawData != null) {
      return rawData
          .map((e) => SaleModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  // 1. Pending Transfers Save Karna
  static Future<void> savePendingTransfers(
    List<GoDownStockTransferToShopModel> list,
  ) async {
    List<Map<String, dynamic>> rawData = list.map((e) => e.toJson()).toList();
    await _box.put(_notifKey, rawData);
  }

  // 2. Pending Transfers Get Karna
  static List<GoDownStockTransferToShopModel> getPendingTransfers() {
    List? rawData = _box.get(_notifKey);
    if (rawData != null) {
      return rawData
          .map(
            (e) => GoDownStockTransferToShopModel.fromJson(
              Map<String, dynamic>.from(e),
              e['id'] ?? '',
            ),
          )
          .toList();
    }
    return [];
  }

  // ================= INVENTORY / PRODUCTS =================

  // 1. All Products Save Karna
  static Future<void> saveProducts(List<ProductModel> products) async {
    List<Map<String, dynamic>> rawData =
        products.map((p) => p.toJson()).toList();
    await _box.put(_productKey, rawData);
  }

  // 2. All Products Load Karna
  static List<ProductModel> getCachedProducts() {
    List? rawData = _box.get(_productKey);
    if (rawData != null) {
      return rawData
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  // 3. Stock Update (Local Cache Sync)
  static Future<void> updateStock(String id, double qty) async {
    // Pehle list nikaalo
    List? rawData = _box.get(_productKey);
    if (rawData != null) {
      List<Map<String, dynamic>> products =
          rawData.map((e) => Map<String, dynamic>.from(e)).toList();

      // Index dhoondo aur update karo
      int index = products.indexWhere((p) => p['id'] == id);
      if (index != -1) {
        products[index]['quantity'] = qty;
        await _box.put(_productKey, products);
      }
    }
  }

  static Future<void> addSaleToLocal(SaleModel newSale) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 1. Purani sales uthao
    List<SaleModel> currentSales = getTodaySales(today);

    // 2. Nayi sale list mein add karo
    currentSales.add(newSale);

    // 3. Wapas Hive mein save kar do
    await saveTodaySales(today, currentSales);

    // 4. Dashboard Stats bhi update karo (Taaki Today Sales ka card badh jaye)
    var stats = getDailyReportStats();
    double currentTotal =
        double.tryParse(stats['total_sales'].toString()) ?? 0.0;
    stats['total_sales'] = currentTotal + newSale.totalAmount;
    await saveDailyReportStats(stats);
  }

  // 4. Multiple Barcode Search (Instruction: [2026-01-31])
  static ProductModel? searchByBarcode(String barcode) {
    try {
      // 1. Hive se saari products ki list lo
      final List<ProductModel> allProducts = getCachedProducts();

      // 2. Barcode match karo (Modern Null Safe tarika)
      // .where use karna zyada safe hai error se bachne ke liye
      final results =
          allProducts.where((p) {
            // Multiple barcodes handle karne ke liye (Aapka rule: Ek product ke multiple barcodes ho sakte hain)
            return p.barcode.toString() == barcode &&
                p.location?.toLowerCase() == 'shop';
            // Agar aapne List<String> barcodes rakhe hain toh: p.barcodes.contains(barcode)
          }).toList();

      if (results.isNotEmpty) {
        return results.first;
      }

      return null; // Agar nahi mila toh null return karo, error nahi aayega
    } catch (e) {
      print("🚨 Local Search Error: $e");
      return null;
    }
  }

  // Jab product update ho, toh Out of Stock wali list ko bhi refresh karo
  static Future<void> syncInventoryAfterSale(
    String productId,
    double soldQty,
  ) async {
    // 1. Main stock update karo
    double currentQty = getLocalStock(productId, false) ?? 0.0;
    double finalQty = currentQty - soldQty;
    await updateStock(productId, finalQty);

    // 2. Agar qty 0 ho gayi hai, toh 'cached_out_of_stock' list update karo
    if (finalQty <= 0) {
      List<ProductModel> outOfStockList = getCachedOutOfStockProducts();
      ProductModel? p = searchByBarcode(
        productId,
      ); // Ya direct product find karo
      if (p != null) {
        outOfStockList.add(p);
        await saveOutOfStockProducts(outOfStockList);
      }
    }
  }

  static Future<void> updatePaymentStats(
    double cash,
    double upi,
    double credit,
  ) async {
    Map<String, dynamic> stats = getDailyReportStats();

    stats['cash_total'] = (stats['cash_total'] ?? 0.0) + cash;
    stats['upi_total'] = (stats['upi_total'] ?? 0.0) + upi;
    stats['credit_total'] = (stats['credit_total'] ?? 0.0) + credit;

    await saveDailyReportStats(stats);
  }

  // ================= LOOSE PRODUCTS =================

  static Future<void> saveLooseProducts(
    List<LooseInvetoryModel> products,
  ) async {
    await _box.put(_productlooseKey, products.map((p) => p.toJson()).toList());
  }

  static List<LooseInvetoryModel> getCachedLooseProducts() {
    List? rawData = _box.get(_productlooseKey);
    return rawData != null
        ? rawData
            .map(
              (e) => LooseInvetoryModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList()
        : [];
  }

  // ================= EXPIRY & OUT OF STOCK =================

  static Future<void> saveExpiryProducts(List<ProductModel> products) async {
    await _box.put(_productExpiryKey, products.map((p) => p.toJson()).toList());
  }

  static List<ProductModel> getCachedExpiryProducts() {
    List? rawData = _box.get(_productExpiryKey);
    return rawData != null
        ? rawData
            .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : [];
  }

  static Future<void> saveOutOfStockProducts(
    List<ProductModel> products,
  ) async {
    await _box.put(
      'cached_out_of_stock',
      products.map((p) => p.toJson()).toList(),
    );
  }

  static List<ProductModel> getCachedOutOfStockProducts() {
    List? rawData = _box.get(_productOutofStockKey);
    return rawData != null
        ? rawData
            .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : [];
  }

  // ================= CATEGORIES =================

  static Future<void> saveCategories(List<CategoryModel> categories) async {
    await _box.put(_categoriesKey, categories.map((e) => e.toJson()).toList());
  }

  static List<CategoryModel> getCachedCategories() =>
      (_box.get(_categoriesKey) as List?)
          ?.map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
      [];

  static Future<void> saveAnimalCategories(
    List<CategoryModel> categories,
  ) async {
    await _box.put(
      _animalCategoriesKey,
      categories.map((e) => e.toJson()).toList(),
    );
  }

  static List<CategoryModel> getCachedAnimalCategories() =>
      (_box.get(_animalCategoriesKey) as List?)
          ?.map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
      [];

  // ================= REPORTS & STATS =================

  static Future<void> saveDailyReportStats(Map<String, dynamic> stats) async {
    await _box.put(_dailyReportStatsKey, stats);
  }

  static Map<String, dynamic> getDailyReportStats() =>
      Map<String, dynamic>.from(_box.get(_dailyReportStatsKey) ?? {});

  static Future<void> saveTopSellingProducts(
    List<ReportTopProductModel> products,
  ) async {
    await _box.put(
      _cachedTopProductKey,
      products.map((e) => e.toJson()).toList(),
    );
  }

  static List<ReportTopProductModel> getCachedTopSellingProducts() =>
      (_box.get(_cachedTopProductKey) as List?)
          ?.map(
            (e) => ReportTopProductModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList() ??
      [];

  // ================= REVENUE / SALES =================

  static Future<void> saveRevenueToLocal(
    String date,
    List<SellsModel> sells,
  ) async {
    await _box.put('revenue_$date', sells.map((e) => e.toJson()).toList());
  }

  static List<SellsModel> getRevenueFromLocal(String date) {
    List? cachedData = _box.get('revenue_$date');
    return cachedData != null
        ? cachedData
            .map((e) => SellsModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : [];
  }

  // ================= DISCOUNTS =================

  static Future<void> saveDiscountsToLocal(
    List<DiscountModel> discounts,
  ) async {
    await _box.put(
      'cached_discounts',
      discounts.map((e) => e.toJson()).toList(),
    );
  }

  static List<DiscountModel> getDiscountsFromLocal() =>
      (_box.get('cached_discounts') as List?)
          ?.map((e) => DiscountModel.fromJson(Map<String, dynamic>.from(e)))
          .toList() ??
      [];

  // ================= STOCK SYNC (FALLBACK) =================

  static Future<void> updateLocalStock(
    String productId,
    double newQty,
    bool isLoose,
  ) async {
    String key = isLoose ? 'loose_stock_$productId' : 'packet_stock_$productId';
    await _box.put(key, newQty);
  }

  // Cache clear karne ke liye (Logout ke waqt kaam aayega)
  static Future<void> clearAllCache() async {
    await _box.clear();
  }

  // 3. Stock Load Karna (Fallback ke liye)
  static double? getLocalStock(String productId, bool isLoose) {
    String key = isLoose ? 'loose_stock_$productId' : 'packet_stock_$productId';
    var data = _box.get(key);

    // Agar individual key mein nahi mila, toh main product list mein dhoondo
    if (data == null) {
      List? rawProducts = _box.get(_productKey);
      if (rawProducts != null) {
        final product = rawProducts.firstWhere(
          (p) => p['id'] == productId,
          orElse: () => null,
        );
        return product != null
            ? double.tryParse(product['quantity'].toString())
            : null;
      }
    }

    return data != null ? double.tryParse(data.toString()) : null;
  }
}
