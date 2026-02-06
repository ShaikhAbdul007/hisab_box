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
    listenShopProducts();
    listenGodownProducts();
    super.onReady();
  }

  // 🔥 SHOP PRODUCTS
  // 🔥 SHOP PRODUCTS (Explicit Relationship Version)
  Future<void> listenShopProducts() async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;

    isDataLoading.value = true;
    try {
      // 💡 Humne yahan 'products!product_stock_product_id_fkey' specify kar diya hai
      final response = await SupabaseConfig.from('product_stock')
          .select('''
        quantity, location, selling_price, discount, stock_type, is_active,
        products!product_stock_product_id_fkey (
          id, name, flavour, weight, rack, level,
          is_loose_category, is_flavor_and_weight_not_required,
          categories(name),
          animal_categories(name),
          stock_batches (
            purchase_date,
            expiry_date,
            purchase_price
          )
        )
      ''')
          .eq('user_id', userId)
          .eq('location', 'shop')
          .eq('is_active', true);

      final List dataList = response as List;
      final shopList =
          dataList.map((e) {
            // Yahan bhi dhyan rakha hai ki product key wahi ho jo join mein di hai
            final productMap = Map<String, dynamic>.from(e['products']);

            productMap['category'] = productMap['categories']?['name'];
            productMap['animal_type'] =
                productMap['animal_categories']?['name'];

            productMap['quantity'] = e['quantity'];
            productMap['selling_price'] = e['selling_price'];
            productMap['location'] = e['location'];
            productMap['discount'] = e['discount'];
            productMap['is_active'] = e['is_active'];
            productMap['is_loose'] = e['stock_type'] == 'loose';

            final batches = productMap['stock_batches'] as List?;
            if (batches != null && batches.isNotEmpty) {
              productMap['purchase_date'] = batches[0]['purchase_date'];
              productMap['expiry_date'] = batches[0]['expiry_date'];
              productMap['purchasePrice'] = batches[0]['purchase_price'];
            }

            return ProductModel.fromJson(productMap);
          }).toList();

      shopProductList.value = shopList;
      updateMainProductList();
      recalculateInventoryDashboardOnly();
    } catch (e) {
      print("Shop Fetch Error: $e");
    } finally {
      isDataLoading.value = false;
    }
  }

  // 🔥 GODOWN PRODUCTS
  void listenGodownProducts() async {
    final userId = SupabaseConfig.auth.currentUser?.id; // Extra safety check
    if (userId == null) return;

    try {
      // 💡 1. Explicit Join: products!product_stock_product_id_fkey use kiya hai
      // 💡 2. stock_batches ko products ke andar move kiya hai
      final response = await SupabaseConfig.from('product_stock')
          .select('''
        quantity, 
        location, 
        selling_price, 
        discount, 
        stock_type, 
        is_active,
        products!product_stock_product_id_fkey (
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
          stock_batches (
            purchase_date,
            expiry_date,
            purchase_price
          )
        )
      ''')
          .eq('user_id', userId)
          .eq('location', 'godown')
          .eq('is_active', true);

      final List dataList = response as List;

      // Agar list khali hai toh debugger mein check karne ke liye:
      if (dataList.isEmpty) {
        print("Godown is empty in DB for user: $userId");
      }

      final godownList =
          dataList.map((e) {
            // Products data path check
            final productMap = Map<String, dynamic>.from(e['products']);

            productMap['category'] = productMap['categories']?['name'];
            productMap['animal_type'] =
                productMap['animal_categories']?['name'];

            productMap['quantity'] = e['quantity'];
            productMap['selling_price'] = e['selling_price'];
            productMap['location'] = e['location'];
            productMap['discount'] = e['discount'];
            productMap['is_active'] = e['is_active'];
            productMap['is_loose'] = e['stock_type'] == 'loose';

            // ✅ Correct Path: stock_batches ab products ke andar hai
            final batches = productMap['stock_batches'] as List?;
            if (batches != null && batches.isNotEmpty) {
              productMap['purchase_date'] = batches[0]['purchase_date'];
              productMap['expiry_date'] = batches[0]['expiry_date'];
              productMap['purchasePrice'] = batches[0]['purchase_price'];
            }

            return ProductModel.fromJson(productMap);
          }).toList();

      goDownProductList.value = godownList;
      updateMainProductList();
      recalculateInventoryDashboardOnly();
    } catch (e) {
      print("Godown Fetch Error: $e");
      // Delivery check: Error dikhana zaroori hai
      showMessage(message: "Godown Error: $e");
    }
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
