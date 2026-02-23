import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';

class LooseCategoryController extends GetxController with LocalService {
  TextEditingController name = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController quantity = TextEditingController();

  final userId = SupabaseConfig.auth.currentUser?.id;
  final isSaveLoading = false.obs;
  final isFetchDiscount = false.obs;
  final isDeleteDiscount = false.obs;
  RxList<ProductModel> looseCategoryModelList = <ProductModel>[].obs;

  @override
  void onInit() {
    fetchLooseCategory();
    super.onInit();
  }

  // ==========================================
  // 🔥 FETCH LOGIC (HIVE + SUPABASE FALLBACK)
  // ==========================================
  Future<void> fetchLooseCategory() async {
    if (userId == null) return;
    isFetchDiscount.value = true;

    // 1. Pehle Hive (Local) se uthao
    final localData =
        LocalService.getCachedProducts()
            .where((p) => p.isLoosed == true || p.sellType == 'loose')
            .toList();

    if (localData.isNotEmpty) {
      looseCategoryModelList.value = localData;
      print("📦 Loose Data from Hive: ${localData.length}");
    }

    try {
      // 2. Supabase Sync (Airtel Handshake handle karne ke liye try-catch)
      final response = await SupabaseConfig.from('product_stock')
          .select('''
            quantity, selling_price, stock_type, 
            products!fk_product_stock_products (
              id, name, flavour, weight, is_loose_category,
              product_barcodes(barcode)
            )
          ''')
          .eq('user_id', userId!)
          .eq('stock_type', 'loose')
          .eq('is_active', true);

      final List dataList = response as List;

      final List<ProductModel> freshList =
          dataList.map((e) {
            final productMap = Map<String, dynamic>.from(e['products']);
            productMap['quantity'] = e['quantity'];
            productMap['selling_price'] = e['selling_price'];
            productMap['sell_type'] = e['stock_type'];
            productMap['is_loose'] = true;

            final List? barcodes = productMap['product_barcodes'] as List?;
            productMap['barcode'] =
                (barcodes != null && barcodes.isNotEmpty)
                    ? barcodes[0]['barcode']
                    : '';

            return ProductModel.fromJson(productMap);
          }).toList();

      looseCategoryModelList.value = freshList;

      // Hive ko refresh karo fresh data se
      LocalService.saveProducts(freshList);
    } catch (e) {
      print("🚨 Fetch Fallback: $e");
    } finally {
      isFetchDiscount.value = false;
    }
  }

  // ==========================================
  // 🔥 ADD LOOSE PRODUCT (SUPABASE INSERT LOGIC)
  // ==========================================
  Future<void> addLooseProduct() async {
    if (userId == null) return;
    if (name.text.isEmpty || price.text.isEmpty) {
      showMessage(message: "Name and Price are required");
      return;
    }

    isSaveLoading.value = true;
    try {
      // 1. Insert into 'products' table first
      final productRes =
          await SupabaseConfig.from('products')
              .insert({
                'user_id': userId,
                'name': name.text,
                'flavour': flavor.text,
                'weight': weight.text,
                'is_loose_category': true,
              })
              .select()
              .single();

      final productId = productRes['id'];

      // 2. Insert into 'product_stock' table
      await SupabaseConfig.from('product_stock').insert({
        'user_id': userId,
        'product_id': productId,
        'quantity': double.tryParse(quantity.text) ?? 0.0,
        'selling_price': double.tryParse(price.text) ?? 0.0,
        'stock_type': 'loose',
        'location': 'shop',
        'is_active': true,
      });

      // 3. Generate a dummy barcode for loose items (if needed for internal tracking)
      String generatedBarcode =
          "LOOSE-${DateTime.now().millisecondsSinceEpoch}";
      await SupabaseConfig.from('product_barcodes').insert({
        'product_id': productId,
        'barcode': generatedBarcode,
        'user_id': userId,
      });

      Get.back();
      showMessage(message: "Loose product saved successfully ✅");
      clear();
      fetchLooseCategory(); // Refresh list to update Hive & UI
    } catch (e) {
      print("🚨 Add Product Error: $e");
      showMessage(message: "Failed to save: Check Internet");
    } finally {
      isSaveLoading.value = false;
    }
  }

  // ==========================================
  // 🔥 DELETE LOGIC (SUPABASE)
  // ==========================================
  Future<void> deleteLooseCategory(String looseCategoryId) async {
    if (userId == null) return;
    isDeleteDiscount.value = true;

    try {
      // Soft delete: is_active ko false kar do
      await SupabaseConfig.from('product_stock')
          .update({'is_active': false})
          .eq('product_id', looseCategoryId)
          .eq('user_id', userId!);

      showMessage(message: "Category deleted successfully");
      fetchLooseCategory();
    } catch (e) {
      print("🚨 Delete Error: $e");
      showMessage(message: "Delete failed: Check Internet");
    } finally {
      isDeleteDiscount.value = false;
    }
  }

  void clear() {
    name.clear();
    weight.clear();
    price.clear();
    flavor.clear();
    quantity.clear();
  }
}
