import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';

class InventoryListController extends GetxController
    with GetSingleTickerProviderStateMixin, CacheManager {
  final userId = SupabaseConfig.auth.currentUser?.id;

  var productList = <ProductModel>[].obs;
  var goDownProductList = <ProductModel>[].obs;
  var shopProductList = <ProductModel>[].obs;

  RxBool isDataLoading = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool isInventoryScanSelected = false.obs;
  RxBool isSea = false.obs;
  RxBool isLoose = false.obs;
  RxBool isFlavorAndWeightNotRequired = false.obs;

  RxString searchText = ''.obs;

  TextEditingController updateQuantity = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController purchasePrice = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController addSubtractQty = TextEditingController();

  TabController? tabController;

  @override
  void onInit() {
    isInventoryScanSelectedValue();
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
  }

  @override
  void onReady() {
    fetchAllInventory();
    super.onReady();
  }

  void fetchAllInventory() async {
    if (userId == null) return;
    await Future.wait([listenShopProducts(), listenGodownProducts()]);
  }

  // 🔥 SHOP PRODUCTS
  // 🔥 SHOP PRODUCTS (Explicit Relationship Version)
  Future<void> listenShopProducts() async {
    if (userId == null) return;
    isDataLoading.value = true;

    try {
      final response = await SupabaseConfig.from('product_stock')
          .select('''
            quantity, location, selling_price, discount, stock_type, is_active,
            products!fk_product_stock_products (
              id, name, flavour, weight, rack, level,
              is_loose_category, is_flavor_and_weight_not_required,
              categories(name),
              animal_categories(name),
              stock_batches!fk_stock_batches_products (
                purchase_date,
                expiry_date,
                purchase_price
              )
            )
          ''')
          .eq('user_id', userId!)
          .eq('location', 'shop')
          .eq('is_active', true);

      final List dataList = response as List;
      shopProductList.value = _mapToProductModel(dataList);
      updateMainProductList();

      print("✅ Shop Data Loaded: ${shopProductList.length} items");
    } catch (e) {
      print("🚨 Shop Fetch Error: $e");
      showMessage(message: "Shop Error: $e");
    } finally {
      isDataLoading.value = false;
    }
  }

  // ================= GODOWN PRODUCTS =================
  Future<void> listenGodownProducts() async {
    if (userId == null) return;

    try {
      final response = await SupabaseConfig.from('product_stock')
          .select('''
            quantity, location, selling_price, discount, stock_type, is_active,
            products!fk_product_stock_products (
              id, name, flavour, weight, rack, level,
              is_loose_category, is_flavor_and_weight_not_required,
              categories(name),
              animal_categories(name),
              stock_batches!fk_stock_batches_products (
                purchase_date,
                expiry_date,
                purchase_price
              )
            )
          ''')
          .eq('user_id', userId!)
          .eq('location', 'godown')
          .eq('is_active', true);

      final List dataList = response as List;
      goDownProductList.value = _mapToProductModel(dataList);
      updateMainProductList();

      print("✅ Godown Data Loaded: ${goDownProductList.length} items");
    } catch (e) {
      print("🚨 Godown Fetch Error: $e");
      showMessage(message: "Godown Error: $e");
    }
  }

  // ================= HELPER: MAPPING LOGIC =================
  List<ProductModel> _mapToProductModel(List dataList) {
    return dataList.map((e) {
      final productMap = Map<String, dynamic>.from(e['products']);

      // Flatten nested data
      productMap['category'] = productMap['categories']?['name'];
      productMap['animal_type'] = productMap['animal_categories']?['name'];
      productMap['quantity'] = e['quantity'];
      productMap['selling_price'] = e['selling_price'];
      productMap['location'] = e['location'];
      productMap['discount'] = e['discount'];
      productMap['is_active'] = e['is_active'];
      productMap['is_loose'] = e['stock_type'] == 'loose';

      // Batch mapping
      final batches = productMap['stock_batches'] as List?;
      if (batches != null && batches.isNotEmpty) {
        productMap['purchase_date'] = batches[0]['purchase_date'];
        productMap['expiry_date'] = batches[0]['expiry_date'];
        productMap['purchasePrice'] = batches[0]['purchase_price'];
      }

      return ProductModel.fromJson(productMap);
    }).toList();
  }

  void updateMainProductList() {
    productList.value = [...shopProductList, ...goDownProductList];
    isDataLoading.value = false;
  }

  void clear() {
    searchController.clear();
    searchText.value = '';
  }

  void controllerClear() {
    addSubtractQty.clear();
  }

  void isInventoryScanSelectedValue() async {
    bool isInventoryScanSelecteds = await retrieveInventoryScan();
    isInventoryScanSelected.value = isInventoryScanSelecteds;
  }

  void searchProduct(String value) {
    searchText.value = value;
    searchController.text = searchText.value;
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }
}
