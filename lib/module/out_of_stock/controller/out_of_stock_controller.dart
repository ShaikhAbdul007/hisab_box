import 'package:inventory/helper/logger.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 Hive Service
import 'package:inventory/helper/helper.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import '../../inventory/model/product_model.dart';

class OutOfStockController extends GetxController
    with CacheManager, LocalService {

  RxBool isDataLoading = false.obs;
  RxBool isDeleteLoading = false.obs;
  var productList = <ProductModel>[].obs;
  RxString searchText = ''.obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    loadOutOfStockProducts();
    super.onInit();
  }

  void clear() {
    searchController.clear();
    searchText.value = '';
  }

  void searchProduct(String value) {
    searchText.value = value;
    searchController.text = searchText.value;
  }

  // 🔥 FLOW: Hive Load -> Supabase Sync -> Hive Update
  Future<void> loadOutOfStockProducts() async {
    final userId = resolveUserId(isDataLoading.value);
    if (userId == null) return;

    // 1️⃣ STEP 1: Pehle Hive (Local DB) se data uthao
    final cachedOutOfStock = LocalService.getCachedOutOfStockProducts();
    if (cachedOutOfStock.isNotEmpty) {
      productList.value = cachedOutOfStock;
      AppLogger.info(("📦 Out of Stock loaded from Hive: ${cachedOutOfStock.length}").toString());
    }

    // 2️⃣ STEP 2: Supabase se fresh data laao (Fallback)
    isDataLoading.value =
        productList.isEmpty; // Loading tabhi jab cache khali ho

    try {
      final response = await SupabaseConfig.from('product_stock')
          .select('''
          id,
          quantity, 
          location, 
          selling_price, 
          discount, 
          stock_type, 
          is_active,
          products!fk_product_stock_products (
            id, 
            name, 
            flavour, 
            weight, 
            rack, 
            level,
            is_loose_category, 
            is_flavor_and_weight_not_required,
            categories(name),
            animal_categories(name),
            product_barcodes(barcode),
            stock_batches!fk_stock_batches_products (
              purchase_date,
              expiry_date
            )
          )
        ''')
          .eq('user_id', userId)
          .eq('quantity', 0)
          .eq('is_active', true)
          .order('updated_at', ascending: false);

      final List dataList = response as List;

      // 3️⃣ STEP 3: Mapping logic
      List<ProductModel> outOfStockList =
          dataList.map((e) {
            final p = e['products'] ?? {};
            final List? barcodes = p['product_barcodes'] as List?;
            final List? batches = p['stock_batches'] as List?;

            Map<String, dynamic> mappedData = {
              ...p,
              'id': e['id'],
              'quantity': e['quantity'],
              'selling_price': e['selling_price'],
              'location': e['location'],
              'discount': e['discount'],
              'stock_type': e['stock_type'],
              'category': p['categories']?['name'],
              'animal_type': p['animal_categories']?['name'],
              'barcode':
                  (barcodes != null && barcodes.isNotEmpty)
                      ? barcodes[0]['barcode']
                      : null,
              'purchase_date':
                  (batches != null && batches.isNotEmpty)
                      ? batches[0]['purchase_date']
                      : null,
              'expiry_date':
                  (batches != null && batches.isNotEmpty)
                      ? batches[0]['expiry_date']
                      : null,
            };

            return ProductModel.fromJson(mappedData);
          }).toList();

      // 4️⃣ STEP 4: UI Refresh aur Hive update
      productList.value = outOfStockList;
      await LocalService.saveOutOfStockProducts(outOfStockList);
      AppLogger.info(("✅ Out of Stock Synced with Supabase & Hive Updated").toString());
    } catch (e) {
      AppLogger.info(("🚨 OutOfStock Fetch Error: $e").toString());
      if (productList.isEmpty) {
        showMessage(message: SupabaseErrorHandler.getMessage(e));
      }
    } finally {
      isDataLoading.value = false;
    }
  }

  // 🔥 UPDATE/DELETE: Supabase Update -> Local UI & Hive Update
  Future<void> deactivateSpecificProduct({required String productId}) async {
    isDeleteLoading.value = true;
    final userId = resolveUserId(isDeleteLoading.value);
    if (userId == null) {
      isDeleteLoading.value = false;
      return;
    }
    try {
      // 1. Supabase Update
      final response =
          await SupabaseConfig.from('product_stock')
              .update({'is_active': false})
              .eq('id', productId)
              .eq('user_id', userId)
              .select();

      if (response.isNotEmpty) {
        showMessage(message: 'Product marked as Inactive');

        // 2. Local Update (Turant UI se hatane ke liye aur Hive sync ke liye)
        productList.removeWhere((item) => item.id == productId);
        await LocalService.saveOutOfStockProducts(productList);

        AppLogger.info(("✅ Inactive Success & Hive Updated locally").toString());
      }

      // 3. Final Sync from server
      await loadOutOfStockProducts();
    } catch (e) {
      AppLogger.info(("🚨 Deactivate Error: $e").toString());
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isDeleteLoading.value = false;
    }
  }
}
