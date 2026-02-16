import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/supabase_db/supabase_client.dart';

import '../../inventory/model/product_model.dart';

class OutOfStockController extends GetxController with CacheManager {
  final uid = SupabaseConfig.auth.currentUser?.id;

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

  Future<void> loadOutOfStockProducts() async {
    if (uid == null) return;
    isDataLoading.value = true;

    try {
      // 1. Direct Supabase Query - Un products ke liye jiniki quantity 0 hai
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
          .eq('user_id', uid!)
          .eq('quantity', 0) // 🔥 Main Filter: Sirf zero quantity wale
          .eq('is_active', true)
          .order('updated_at', ascending: false);

      final List dataList = response as List;
      print("🚩 Out of Stock Items Found: ${dataList.length}");

      // 2. Mapping to ProductModel
      List<ProductModel> outOfStockList =
          dataList.map((e) {
            final p = e['products'] ?? {};
            final List? barcodes = p['product_barcodes'] as List?;
            final List? batches = p['stock_batches'] as List?;

            // ProductModel ke variables ke saath mapping
            Map<String, dynamic> mappedData = {
              ...p,
              'id': e['id'], // product_stock ki ID
              'quantity': e['quantity'],
              'selling_price': e['selling_price'],
              'location': e['location'],
              'discount': e['discount'],
              'stock_type': e['stock_type'],
              'category': p['categories']?['name'],
              'animal_type': p['animal_categories']?['name'],
              'barcodes':
                  (barcodes != null && barcodes.isNotEmpty)
                      ? barcodes[0]['barcode']
                      : null,
              'purchase_date':
                  (batches != null && batches.isNotEmpty)
                      ? batches[0]['purchase_date']
                      : 0.0,
              'expiry_date':
                  (batches != null && batches.isNotEmpty)
                      ? batches[0]['expiry_date']
                      : null,
            };

            return ProductModel.fromJson(mappedData);
          }).toList();

      // 3. Update the UI List
      productList.value = outOfStockList;
    } catch (e) {
      print("🚨 OutOfStock Fetch Error: $e");
      showMessage(message: "Error loading out of stock products");
    } finally {
      isDataLoading.value = false;
    }
  }

  // 'int productId' ko badal kar 'String productId' kar do
  Future<void> deactivateSpecificProduct({required String productId}) async {
    isDeleteLoading.value = true;
    try {
      // 🎯 Filter 'id' par lagao, 'product_id' par nahi
      final response =
          await SupabaseConfig.from('product_stock')
              .update({'is_active': false})
              .eq('id', productId)
              .eq('user_id', uid ?? '')
              .select(); // Select se confirm hoga ki update hua ya nahi

      if (response.isNotEmpty) {
        showMessage(message: 'Product marked as Inactive');
        print("✅ Update Success: $response");
      } else {
        print("⚠️ No row found with ID: $productId");
      }

      // 2. Refresh the list (Await lagana zaroori hai)
      await loadOutOfStockProducts();
    } catch (e) {
      print("🚨 Deactivate Error: $e");
      showMessage(message: "Failed to deactivate: $e");
    } finally {
      isDeleteLoading.value = false;
    }
  }
}
