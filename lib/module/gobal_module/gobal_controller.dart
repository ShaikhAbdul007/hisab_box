import 'package:inventory/helper/logger.dart';
import 'dart:async';

import 'package:get/get.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/module/revenue/model/revenue_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inventory/helper/helper.dart';

class GlobalStore extends GetxController {
  final _supabase = SupabaseConfig.client;
  StreamSubscription<AuthState>? _authSub;
  RealtimeChannel? _realtimeChannel;
  final Set<int> _optimisticBillNos = <int>{};

  // --- Observables ---
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<LooseInvetoryModel> allLooseProducts =
      <LooseInvetoryModel>[].obs;
  final RxList<SellsModel> allSalesList =
      <SellsModel>[].obs; // 🔥 Realtime Sales List
  var barcodeToProductMap = <String, ProductModel>{}.obs;
  bool _hasShownSyncError = false;

  RxBool isInitialDataLoaded = false.obs;

  // Totals for Reports/Revenue
  var cashTotal = 0.0.obs;
  var upiTotal = 0.0.obs;
  var creditTotal = 0.0.obs;
  var cardTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromHive();
    _bindAuthSync();
    loadInitialData();
    startRealtimeSync();
  }

  void _bindAuthSync() {
    _authSub = SupabaseConfig.auth.onAuthStateChange.listen((event) async {
      final authEvent = event.event;

      if (authEvent == AuthChangeEvent.signedIn ||
          authEvent == AuthChangeEvent.tokenRefreshed ||
          authEvent == AuthChangeEvent.userUpdated) {
        await loadInitialData();
        startRealtimeSync();
      } else if (authEvent == AuthChangeEvent.signedOut) {
        _realtimeChannel?.unsubscribe();
        _realtimeChannel = null;
        allProducts.clear();
        allLooseProducts.clear();
        allSalesList.clear();
        barcodeToProductMap.clear();
        isInitialDataLoaded.value = false;
      }
    });
  }

  // 1. Initial Load (Heavy Lifting)
  Future<void> loadInitialData() async {
    try {
      final uId = SupabaseConfig.auth.currentUser?.id;
      if (uId == null) {
        AppLogger.info(("🚨 UID is NULL").toString());
        return;
      }

      // Har fetch independently guarded hai, taaki ek failure par sab data wipe na ho.
      final stockData = await _safeFetchStock(uId);
      final looseData = await _safeFetchLoose(uId);
      final salesData = await _safeFetchTodaySales(uId);

      if (stockData != null) allProducts.assignAll(stockData);
      if (looseData != null) allLooseProducts.assignAll(looseData);
      if (salesData != null) allSalesList.assignAll(salesData);

      updateBarcodeMapFromList(allProducts);
      _calculateTotalsFromSales();

      // Hive sync only with latest RAM snapshot
      await LocalService.saveProducts(allProducts);
      await LocalService.saveLooseProducts(allLooseProducts);

      isInitialDataLoaded.value = true;
      _hasShownSyncError = false;
      allProducts.refresh();
      AppLogger.info(("🚀 GlobalStore: Sync Complete. Products: ${allProducts.length}").toString());
    } catch (e) {
      _notifySyncError(e);
    }
  }

  Future<List<ProductModel>?> _safeFetchStock(String uId) async {
    try {
      return await _fetchStock(uId);
    } catch (e) {
      _notifySyncError(e);
      return null;
    }
  }

  Future<List<LooseInvetoryModel>?> _safeFetchLoose(String uId) async {
    try {
      return await _fetchLoose(uId);
    } catch (e) {
      _notifySyncError(e);
      return null;
    }
  }

  Future<List<SellsModel>?> _safeFetchTodaySales(String uId) async {
    try {
      return await _fetchTodaySales(uId);
    } catch (e) {
      _notifySyncError(e);
      return null;
    }
  }

  void _loadFromHive() {
    try {
      allProducts.assignAll(LocalService.getCachedProducts());
      allLooseProducts.assignAll(LocalService.getCachedLooseProducts());
      updateBarcodeMapFromList(allProducts);
    } catch (e) {
      _notifySyncError(e);
    }
  }

  // --- Realtime Sync ---
  void startRealtimeSync() {
    final uId = SupabaseConfig.auth.currentUser?.id;
    if (uId == null) return;

    _realtimeChannel?.unsubscribe();
    _realtimeChannel =
        _supabase
            .channel('global_sync_$uId')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'sales',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: uId,
              ),
              callback: (payload) async {
                final newSale = await _fetchSingleSale(payload.newRecord['id']);
                if (newSale != null) {
                  final bool wasOptimistic = _consumeOptimisticBill(newSale.billNo);
                  _upsertSaleInMemory(newSale);
                  if (!wasOptimistic) {
                    _updateTotalsFromNewSale(newSale);
                  }
                }
              },
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'sales',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: uId,
              ),
              callback: (_) async {
                await loadInitialData();
              },
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.delete,
              schema: 'public',
              table: 'sales',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: uId,
              ),
              callback: (_) async {
                await loadInitialData();
              },
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'sale_payments',
              callback: (payload) async {
                final dynamic saleId =
                    payload.newRecord['sale_id'] ?? payload.oldRecord['sale_id'];
                if (saleId == null) return;

                final bool isOwnSale = await _isSaleOwnedByCurrentUser(
                  saleId.toString(),
                  uId,
                );
                if (isOwnSale) {
                  await loadInitialData();
                }
              },
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'product_stock',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uId,
          ),
          callback: (payload) {
            _updateLocalStock(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'loose_stocks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uId,
          ),
          callback: (payload) {
            _updateLocalLooseStock(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: uId,
          ),
          callback: (_) async {
            await loadInitialData();
          },
        )
        .subscribe();
  }

  Future<bool> _isSaleOwnedByCurrentUser(String saleId, String userId) async {
    try {
      final res =
          await _supabase
              .from('sales')
              .select('id')
              .eq('id', saleId)
              .eq('user_id', userId)
              .maybeSingle();
      return res != null;
    } catch (e) {
      AppLogger.error('Failed to validate sale owner', e, 'GlobalStore');
      return false;
    }
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
      final List? barcodeList = pMap['product_barcodes'] as List?;
      pMap['barcode'] =
          (barcodeList != null && barcodeList.isNotEmpty)
              ? barcodeList[0]['barcode']?.toString()
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

  Future<List<SellsModel>> _fetchTodaySales(
    String uId, {
    DateTime? date,
  }) async {
    // 1️⃣ Timezone Logic (Jo tumhara working tha)
    final DateTime targetDate = date ?? DateTime.now();

    final DateTime targetOnlyDate = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    try {
      final response = await _supabase
          .from('sales')
          .select('''
          id, bill_no, total_amount, created_at,
          customers (name, mobile_number),
          sale_items (
            qty, final_price, original_price, product_id, stock_type, location, applied_discount_percent,
            products (
              name, weight, flavour,
              categories:category (name),
              animal_categories:animal_type (name),
              product_barcodes(barcode)
            )
          ),
          sale_payments ( amount, payment_mode, reference_no, cash_amount, upi_amount, card_amount, credit_amount, round_off_amount )
        ''')
          .eq('user_id', uId)
          .order('created_at', ascending: false)
          .limit(500);

      final List rawData = response as List;
      final List data =
          rawData.where((sale) {
            final String createdAt = sale['created_at']?.toString() ?? '';
            final DateTime? parsed = DateTime.tryParse(createdAt);
            if (parsed == null) return false;
            final local = parsed.toLocal();
            return local.year == targetOnlyDate.year &&
                local.month == targetOnlyDate.month &&
                local.day == targetOnlyDate.day;
          }).toList();

      AppLogger.info(("Fetched Today's Sales: ${data.length}").toString());
      return data.map((sale) {
        final List dbItems = sale['sale_items'] ?? [];
        final List dbPayments = sale['sale_payments'] ?? [];

        // 2️⃣ Items Mapping (Tumhare working logic ke hisaab se)
        List<SellItem> mappedItems =
            dbItems.map((item) {
              final p = Map<String, dynamic>.from(item['products'] ?? {});
              final categoryMap = Map<String, dynamic>.from(p['categories'] ?? {});
              final animalMap = Map<String, dynamic>.from(
                p['animal_categories'] ?? {},
              );
              final List barcodes = (p['product_barcodes'] as List?) ?? [];
              return SellItem(
                name: p['name'] ?? 'Unknown',
                quantity: item['qty'] ?? 0,
                originalPrice: (item['original_price'] ?? 0).toDouble(),
                finalPrice: (item['final_price'] ?? 0).toDouble(),
                discount: item['applied_discount_percent'] ?? 0,
                barcode:
                    barcodes.isNotEmpty
                        ? barcodes[0]['barcode']
                        : '',
                id: item['product_id'],
                weight: p['weight'] ?? '',
                flavours: p['flavour'] ?? '',
                category: categoryMap['name']?.toString() ?? '',
                animalType: animalMap['name']?.toString() ?? '',
                location: item['location'] ?? 'shop',
                sellType: item['stock_type'] ?? 'packet',
              );
            }).toList();

        // 3️⃣ Payment Modes (Working Logic)
        final p = dbPayments.isNotEmpty ? dbPayments[0] : {};
        PaymentModel paymentObj = PaymentModel(
          cash: (p['cash_amount'] ?? 0).toDouble(),
          upi: (p['upi_amount'] ?? 0).toDouble(),
          card: (p['card_amount'] ?? 0).toDouble(),
          credit: (p['credit_amount'] ?? 0).toDouble(),
          totalAmount: (sale['total_amount'] ?? 0).toDouble(),
          isRoundOff: false,
          roundOffAmount: (p['round_off_amount'] ?? 0).toDouble(),
          type: p['payment_mode'] ?? 'Cash',
        );

        // 4️⃣ Final Model (With Date & Time split as you wanted)
        return SellsModel(
          billNo:
              sale['bill_no'] != null
                  ? int.tryParse(sale['bill_no'].toString())
                  : null,
          totalAmount: (sale['total_amount'] ?? 0).toDouble(),
          finalAmount: (sale['total_amount'] ?? 0).toDouble(),
          customerName: sale['customers']?['name'] ?? '',
          customerMobile: sale['customers']?['mobile_number'] ?? '',
          itemsCount: mappedItems.length,
          soldAt: sale['created_at'].toString().split('T')[0], // YYYY-MM-DD
          time:
              sale['created_at']
                  .toString()
                  .split('T')[1]
                  .split('.')[0], // HH:mm:ss
          items: mappedItems,
          payment: paymentObj,
        );
      }).toList();
    } catch (e) {
      _notifySyncError(e);
      return [];
    }
  }

  Future<List<SellsModel>> fetchSalesByDate(DateTime date) async {
    final uId = SupabaseConfig.auth.currentUser?.id;
    if (uId == null) return [];
    return _fetchTodaySales(uId, date: date);
  }

  Future<SellsModel?> _fetchSingleSale(dynamic id) async {
    try {
      final response =
          await _supabase
              .from('sales')
              .select('''
        id, bill_no, total_amount, created_at,
        customers (name, mobile_number),
        sale_items (
          qty, final_price, original_price, product_id, stock_type, location, applied_discount_percent,
          products (
            name, weight, flavour,
            categories:category (name),
            animal_categories:animal_type (name),
            product_barcodes(barcode)
          )
        ),
        sale_payments (payment_mode, cash_amount, upi_amount, card_amount, credit_amount, round_off_amount)
      ''')
              .eq('id', id)
              .single();

      final map = Map<String, dynamic>.from(response);

      // 1. Root Level Mapping
      map['billNo'] = map['bill_no'];
      map['totalAmount'] = map['total_amount'];
      map['soldAt'] = map['created_at'];

      // 2. Customer Mapping
      if (map['customers'] != null) {
        map['customerName'] = map['customers']['name'];
        map['customerMobile'] = map['customers']['mobile_number'];
      }

      // 3. Items Mapping (SellItem model ke liye)
      if (map['sale_items'] != null) {
        map['items'] =
            (map['sale_items'] as List).map((item) {
              final p = item['products'] ?? {};
              return {
                'id': item['product_id'],
                'name': p['name'],
                'quantity': item['qty'],
                'discount': item['applied_discount_percent'] ?? 0,
                'finalPrice': item['final_price'],
                'originalPrice': item['original_price'],
                'weight': p['weight'],
                'flavours': p['flavour'],
                'category':
                    p['categories'] != null ? p['categories']['name'] : '',
                'animalType':
                    p['animal_categories'] != null
                        ? p['animal_categories']['name']
                        : '',
                'location': item['location'] ?? 'shop',
                'sellType': item['stock_type'] ?? 'packet',
                'barcode':
                    (p['product_barcodes'] != null &&
                            (p['product_barcodes'] as List).isNotEmpty)
                        ? p['product_barcodes'][0]['barcode']
                        : '',
              };
            }).toList();
      }

      // 4. Payment Mapping (PaymentModel ke liye)
      if (map['sale_payments'] != null &&
          (map['sale_payments'] as List).isNotEmpty) {
        final p = map['sale_payments'][0];
        map['payment'] = {
          'cash': p['cash_amount'],
          'upi': p['upi_amount'],
          'card': p['card_amount'],
          'credit': p['credit_amount'],
          'totalAmount': map['total_amount'],
          'roundOffAmount': p['round_off_amount'],
          'type': p['payment_mode'],
        };
      }

      return SellsModel.fromJson(map);
    } catch (e) {
      _notifySyncError(e);
      return null;
    }
  }

  void _notifySyncError(dynamic error) {
    final String message = SupabaseErrorHandler.getMessage(error);
    AppLogger.error('Global sync error', error, 'GlobalStore');
    if (_hasShownSyncError) return;
    _hasShownSyncError = true;
  showSnackBar(error: message);
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

  void _upsertSaleInMemory(SellsModel sale) {
    final int idx = allSalesList.indexWhere((s) => s.billNo == sale.billNo);
    if (idx == -1) {
      allSalesList.insert(0, sale);
    } else {
      allSalesList[idx] = sale;
      allSalesList.refresh();
    }
  }

  void markOptimisticBill(int? billNo) {
    if (billNo == null) return;
    _optimisticBillNos.add(billNo);
  }

  bool _consumeOptimisticBill(int? billNo) {
    if (billNo == null) return false;
    return _optimisticBillNos.remove(billNo);
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
      if (p.barcode != null && p.barcode!.isNotEmpty) {
        barcodeToProductMap[p.barcode!] = p;
      }
    }
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _realtimeChannel?.unsubscribe();
    super.onClose();
  }
}
