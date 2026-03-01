import 'package:get/get.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/module/revenue/model/revenue_model.dart';
import 'package:inventory/module/sell/model/sell_model.dart'; // SellsModel path
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GlobalStore extends GetxController {
  final _supabase = SupabaseConfig.client;

  // --- Observables ---
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<LooseInvetoryModel> allLooseProducts =
      <LooseInvetoryModel>[].obs;
  final RxList<SellsModel> allSalesList =
      <SellsModel>[].obs; // 🔥 Realtime Sales List
  var barcodeToProductMap = <String, ProductModel>{}.obs;

  RxBool isInitialDataLoaded = false.obs;

  // Totals for Reports/Revenue
  var cashTotal = 0.0.obs;
  var upiTotal = 0.0.obs;
  var creditTotal = 0.0.obs;
  var cardTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    startRealtimeSync();
  }

  // 1. Initial Load (Heavy Lifting)
  Future<void> loadInitialData() async {
    try {
      final uId = SupabaseConfig.auth.currentUser?.id;
      if (uId == null) return;

      // Sabse pehle Hive se data uthao (Bina internet ke bhi app chalu ho jaye)
      _loadFromHive();

      // Parallel Fetching: Stock, Loose, aur Sales ek sath
      final results = await Future.wait([
        _fetchStock(uId),
        _fetchLoose(uId),
        _fetchTodaySales(uId),
      ]);

      // Update RAM and Hive
      allProducts.assignAll(results[0] as List<ProductModel>);
      allLooseProducts.assignAll(results[1] as List<LooseInvetoryModel>);
      allSalesList.assignAll(results[2] as List<SellsModel>);

      updateBarcodeMapFromList(allProducts);
      _calculateTotalsFromSales(); // Sales list se totals nikal lo

      // Hive Update
      LocalService.saveProducts(allProducts);
      LocalService.saveLooseProducts(allLooseProducts);

      isInitialDataLoaded.value = true;
      print("🚀 GlobalStore: Sync Complete");
    } catch (e) {
      print("🚨 Global Load Error: $e");
    }
  }

  void _loadFromHive() {
    allProducts.assignAll(LocalService.getCachedProducts());
    allLooseProducts.assignAll(LocalService.getCachedLooseProducts());
    updateBarcodeMapFromList(allProducts);
  }

  // --- Realtime Sync ---
  void startRealtimeSync() {
    _supabase
        .channel('global_sync')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          callback: (payload) async {
            final table = payload.table;
            final newData = payload.newRecord;

            if (table == 'sales' &&
                payload.eventType == PostgresChangeEvent.insert) {
              // 🔥 Naya Bill Aaya: Direct full detail fetch karo aur list ke top par dalo
              final newSale = await _fetchSingleSale(newData['id']);
              if (newSale != null) {
                allSalesList.insert(0, newSale);
                _updateTotalsFromNewSale(
                  newSale,
                ); // Totals update karo realtime
              }
            } else if (table == 'product_stock') {
              _updateLocalStock(newData);
            } else if (table == 'loose_stocks') {
              _updateLocalLooseStock(newData);
            } else if (table == 'products') {
              loadInitialData(); // Product info badli toh refresh
            }
          },
        )
        .subscribe();
  }

  // --- Fetchers & Mappers ---

  Future<List<ProductModel>> _fetchStock(String uId) async {
    final response = await _supabase
        .from('product_stock')
        .select('''
        quantity, location, selling_price, discount, stock_type, is_active,
        products!fk_product_stock_products (
          id, name, flavour, weight, rack, level,
          is_loose_category, is_flavor_and_weight_not_required,
          categories(name), animal_categories(name),
          product_barcodes(barcode),
          stock_batches!fk_stock_batches_products (purchase_date, expiry_date, purchase_price)
        )
      ''')
        .eq('user_id', uId)
        .eq('is_active', true);

    return (response as List).map((e) {
      final pMap = Map<String, dynamic>.from(e['products'] ?? {});
      pMap['category'] = pMap['categories']?['name'];
      pMap['animal_type'] = pMap['animal_categories']?['name'];
      pMap['quantity'] = e['quantity'];
      pMap['selling_price'] = e['selling_price'];
      pMap['location'] = e['location'];
      pMap['discount'] = e['discount'];
      pMap['stock_type'] = e['stock_type'];
      pMap['barcode'] =
          (pMap['product_barcodes'] as List).isNotEmpty
              ? pMap['product_barcodes'][0]['barcode']
              : '';
      final batches = pMap['stock_batches'] as List?;
      if (batches != null && batches.isNotEmpty) {
        pMap['purchase_date'] = batches[0]['purchase_date'];
        pMap['expiry_date'] = batches[0]['expiry_date'];
        pMap['purchase_price'] = batches[0]['purchase_price'];
      }
      return ProductModel.fromJson(pMap);
    }).toList();
  }

  Future<List<LooseInvetoryModel>> _fetchLoose(String uId) async {
    final response = await _supabase
        .from('loose_stocks')
        .select('''
          id, quantity, selling_price, product_id, user_id, created_at, updated_at,
          products!fk_loose_stocks_products (
            id, name, flavour, weight, rack, level,
            is_loose_category, is_flavor_and_weight_not_required,
            categories:category (id, name), 
            animals:animal_type (id, name),
            product_barcodes!fk_product_barcodes_products (barcode),
            product_stock!fk_product_stock_products (location, stock_type, is_active),
            stock_batches (purchase_date, expiry_date, purchase_price, location, stock_type)
          )
        ''')
        .eq('user_id', uId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => LooseInvetoryModel.fromJson(e))
        .toList();
  }

  Future<List<SellsModel>> _fetchTodaySales(String uId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _supabase
        .from('sales')
        .select('''
        id, bill_no, total_amount, created_at,
        customers (name, mobile_number),
        sale_items (qty, final_price, original_price, product_id, stock_type, products(name, weight, product_barcodes(barcode))),
        sale_payments (payment_mode, cash_amount, upi_amount, card_amount, credit_amount, round_off_amount)
      ''')
        .eq('user_id', uId)
        .gte('created_at', "${today}T00:00:00Z")
        .order('created_at', ascending: false);

    return (response as List).map((e) => SellsModel.fromJson(e)).toList();
  }

  Future<SellsModel?> _fetchSingleSale(dynamic id) async {
    final response =
        await _supabase
            .from('sales')
            .select('''
        id, bill_no, total_amount, created_at,
        customers (name, mobile_number),
        sale_items (qty, final_price, original_price, product_id, stock_type, products(name, weight, product_barcodes(barcode))),
        sale_payments (payment_mode, cash_amount, upi_amount, card_amount, credit_amount, round_off_amount)
      ''')
            .eq('id', id)
            .single();
    return SellsModel.fromJson(response);
  }

  // --- Logic Helpers ---

  void _calculateTotalsFromSales() {
    cashTotal.value = 0;
    upiTotal.value = 0;
    cardTotal.value = 0;
    creditTotal.value = 0;
    for (var sale in allSalesList) {
      _updateTotalsFromNewSale(sale);
    }
  }

  void _updateTotalsFromNewSale(SellsModel sale) {
    cashTotal.value += (sale.payment?.cash ?? 0);
    upiTotal.value += (sale.payment?.upi ?? 0);
    cardTotal.value += (sale.payment?.card ?? 0);
    creditTotal.value += (sale.payment?.credit ?? 0);
  }

  void _updateLocalStock(Map<String, dynamic> newData) {
    final String pId = newData['product_id']?.toString() ?? '';
    final int idx = allProducts.indexWhere((p) => p.id?.toString() == pId);
    if (idx != -1) {
      allProducts[idx].quantity =
          num.tryParse(newData['quantity']?.toString() ?? '0') ?? 0;
      allProducts.refresh();
      LocalService.saveProducts(allProducts);
    }
  }

  void _updateLocalLooseStock(Map<String, dynamic> newData) {
    final String id = newData['id']?.toString() ?? '';
    final int idx = allLooseProducts.indexWhere((p) => p.id?.toString() == id);
    if (idx != -1) {
      allLooseProducts[idx].quantity =
          num.tryParse(newData['quantity']?.toString() ?? '0')?.toInt() ?? 0;
      allLooseProducts.refresh();
      LocalService.saveLooseProducts(allLooseProducts);
    }
  }

  void updateBarcodeMapFromList(List<ProductModel> products) {
    barcodeToProductMap.clear();
    for (var p in products) {
      if (p.barcode != null && p.barcode!.isNotEmpty)
        barcodeToProductMap[p.barcode!] = p;
    }
  }
}
