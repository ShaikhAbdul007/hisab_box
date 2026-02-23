import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import '../../../helper/helper.dart';
import '../../loose_category/model/loose_category_model.dart';
import '../model/loose_model.dart';

class LooseController extends GetxController with LocalService {
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController updateQuantity = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController addSubtractQty = TextEditingController();
  TextEditingController newSellingPrice = TextEditingController();
  TextEditingController name = TextEditingController();

  RxBool isDataLoading = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool isInventoryScanSelected = false.obs;

  var productList = <LooseInvetoryModel>[].obs;
  String? id;
  RxList<LooseCategoryModel> looseCategoryModelList =
      <LooseCategoryModel>[].obs;
  RxString searchText = ''.obs;

  final userId = SupabaseConfig.auth.currentUser?.id;

  @override
  void onInit() {
    fetchLosseList();
    super.onInit();
  }

  void fetchLosseList() async {
    await fetchLooseProduct();
  }

  // 🔥 FLOW: Hive -> Supabase -> Hive Update
  Future<void> fetchLooseProduct() async {
    if (userId == null) return;

    // 1. Pehle Hive se data lo (Instant UI Show)
    final cachedData = LocalService.getCachedLooseProducts();
    if (cachedData.isNotEmpty) {
      productList.value = cachedData;
      print("📦 Hive se data mil gaya: ${cachedData.length}");
    }

    // 2. Supabase se fetch karo (Fallback & Update)
    isDataLoading.value =
        productList.isEmpty; // Loading tabhi jab cache khali ho
    try {
      final response = await SupabaseConfig.from('loose_stocks')
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
          .eq('user_id', userId!)
          .order('created_at', ascending: false);

      final List data = response as List;
      final List<LooseInvetoryModel> freshList =
          data.map((e) => LooseInvetoryModel.fromJson(e)).toList();

      // 3. UI Update aur Hive Update
      productList.value = freshList;
      await LocalService.saveLooseProducts(freshList);
      print("✅ Supabase se data sync ho gaya aur Hive update ho gaya");
    } catch (e) {
      print("🚨 Fetch Error: $e");
      if (productList.isEmpty)
        showMessage(message: "Check internet connection");
    } finally {
      isDataLoading.value = false;
    }
  }

  // 🔥 UPDATE: Supabase Update -> Hive Refresh
  void updateProductQuantity({
    required String barcode,
    required bool add,
  }) async {
    if (userId == null) return;
    isSaveLoading.value = true;
    try {
      final response =
          await SupabaseConfig.from('product_stock')
              .select('quantity')
              .eq('product_id', barcode)
              .eq('user_id', userId!)
              .maybeSingle();

      if (response != null) {
        final num prevQty = response['quantity'] ?? 0;
        final num newQtyInput = num.tryParse(addSubtractQty.text) ?? 0;
        final double sPrice = double.tryParse(sellingPrice.text) ?? 0.0;
        final num finalQty =
            add ? prevQty + newQtyInput : prevQty - newQtyInput;

        // Supabase Update
        await SupabaseConfig.from('product_stock')
            .update({'quantity': finalQty, 'selling_price': sPrice})
            .eq('product_id', barcode)
            .eq('user_id', userId!);

        Get.back();
        qtyClear();
        showMessage(message: '✅ Quantity updated in Cloud & Hive.');

        // Refresh Flow (Auto updates Hive)
        await fetchLooseProduct();
      }
    } catch (e) {
      print("🚨 Update Error: $e");
      showMessage(message: "Update failed: No Internet");
    } finally {
      isSaveLoading.value = false;
    }
  }

  void qtyClear() {
    addSubtractQty.clear();
  }

  void searchProduct(String value) {
    searchText.value = value;
    searchController.text = searchText.value;
  }

  void setQuantitydata(int index) {
    sellingPrice.text = productList[index].sellingPrice.toString();
    updateQuantity.text = productList[index].quantity.toString();
  }

  void clear() {
    quantity.clear();
    amount.clear();
  }
}
