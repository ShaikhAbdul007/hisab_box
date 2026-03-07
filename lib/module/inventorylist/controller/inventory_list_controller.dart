// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:inventory/cache_manager/cache_manager.dart';
// import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService import
// import 'package:inventory/module/inventory/model/product_model.dart';
// import 'package:inventory/supabase_db/supabase_client.dart';

// class InventoryListController extends GetxController
//     with GetSingleTickerProviderStateMixin, CacheManager, LocalService {
//   final userId = SupabaseConfig.auth.currentUser?.id;

//   var productList = <ProductModel>[].obs;
//   var goDownProductList = <ProductModel>[].obs;
//   var shopProductList = <ProductModel>[].obs;

//   RxBool isDataLoading = false.obs;
//   RxBool isSaveLoading = false.obs;
//   RxBool isInventoryScanSelected = false.obs;
//   RxBool isSea = false.obs;
//   RxBool isLoose = false.obs;
//   RxBool isFlavorAndWeightNotRequired = false.obs;

//   RxString searchText = ''.obs;

//   TextEditingController updateQuantity = TextEditingController();
//   TextEditingController name = TextEditingController();
//   TextEditingController sellingPrice = TextEditingController();
//   TextEditingController flavor = TextEditingController();
//   TextEditingController weight = TextEditingController();
//   TextEditingController purchasePrice = TextEditingController();
//   TextEditingController searchController = TextEditingController();
//   TextEditingController addSubtractQty = TextEditingController();

//   TabController? tabController;

//   @override
//   void onInit() {
//     isInventoryScanSelectedValue();
//     tabController = TabController(length: 2, vsync: this);
//     super.onInit();
//   }

//   @override
//   void onReady() {
//     fetchAllInventory();
//     super.onReady();
//   }

//   // 🔥 MODIFIED: Pehle Local DB se data dikhayega, phir Supabase se sync karega
//   void fetchAllInventory() async {
//     isDataLoading.value = true;
//     if (userId == null) return;

//     // 1. Instant Loading from Hive
//     final cachedData = LocalService.getCachedProducts();
//     if (cachedData.isNotEmpty) {
//       productList.value = cachedData;
//       // UI ko categorize karna zaroori hai local data ke liye bhi
//       shopProductList.value =
//           cachedData.where((p) => p.location == 'shop').toList();
//       goDownProductList.value =
//           cachedData.where((p) => p.location == 'godown').toList();
//       print("📦 Local Data Loaded Successfully");
//     } else {
//       // 2. Network Sync in Background
//       await Future.wait([listenShopProducts(), listenGodownProducts()]);
//     }

//     isDataLoading.value = false;
//   }

//   Future<void> listenShopProducts() async {
//     if (userId == null) return;
//     // Loading tabhi true karo agar local data na ho, taaki screen flicker na kare
//     if (productList.isEmpty) isDataLoading.value = true;

//     try {
//       final response = await SupabaseConfig.from('product_stock')
//           .select('''
//             quantity, location, selling_price, discount, stock_type, is_active,
//             products!fk_product_stock_products (
//               id, name, flavour, weight, rack, level,
//               is_loose_category, is_flavor_and_weight_not_required,
//               categories(name),
//               animal_categories(name),
//               product_barcodes(barcode),
//               stock_batches!fk_stock_batches_products (
//                 purchase_date,
//                 expiry_date,
//                 purchase_price
//               )
//             )
//           ''')
//           .eq('user_id', userId!)
//           .eq('location', 'shop')
//           .eq('is_active', true);

//       final List dataList = response as List;
//       shopProductList.value = _mapToProductModel(dataList);
//       updateMainProductList();

//       print("✅ Shop Data Loaded: ${shopProductList.length} items");
//     } catch (e) {
//       print("🚨 Shop Fetch Error: $e");
//       // Agar handshake error aaye, toh user ko batado par data screen par rahega
//       // showMessage(message: "Using offline data. Error: $e");
//     } finally {
//       isDataLoading.value = false;
//     }
//   }

//   Future<void> listenGodownProducts() async {
//     if (userId == null) return;

//     try {
//       final response = await SupabaseConfig.from('product_stock')
//           .select('''
//             quantity, location, selling_price, discount, stock_type, is_active,
//             products!fk_product_stock_products (
//               id, name, flavour, weight, rack, level,
//               is_loose_category, is_flavor_and_weight_not_required,
//               categories(name),
//               animal_categories(name),
//               product_barcodes(barcode),
//               stock_batches!fk_stock_batches_products (
//                 purchase_date,
//                 expiry_date,
//                 purchase_price
//               )
//             )
//           ''')
//           .eq('user_id', userId!)
//           .eq('location', 'godown')
//           .eq('is_active', true);

//       final List dataList = response as List;
//       goDownProductList.value = _mapToProductModel(dataList);
//       updateMainProductList();

//       print("✅ Godown Data Loaded: ${goDownProductList.length} items");
//     } catch (e) {
//       print("🚨 Godown Fetch Error: $e");
//     }
//   }

//   List<ProductModel> _mapToProductModel(List dataList) {
//     return dataList.map((e) {
//       final productMap = Map<String, dynamic>.from(e['products']);

//       productMap['category'] = productMap['categories']?['name'];
//       productMap['animal_type'] = productMap['animal_categories']?['name'];
//       productMap['quantity'] = e['quantity'];
//       productMap['selling_price'] = e['selling_price'];
//       productMap['location'] = e['location'];
//       productMap['discount'] = e['discount'];
//       productMap['is_active'] = e['is_active'];
//       productMap['is_loose'] = e['stock_type'] == 'loose';

//       final List? barcodeList = productMap['product_barcodes'] as List?;
//       if (barcodeList != null && barcodeList.isNotEmpty) {
//         productMap['barcode'] = barcodeList[0]['barcode']?.toString();
//         // 🔥 Multi-barcode support ke liye poori list ko JSON mein daal rahe hain
//         productMap['all_barcodes'] =
//             barcodeList.map((b) => b['barcode'].toString()).toList();
//       } else {
//         productMap['barcode'] = '';
//         productMap['all_barcodes'] = [];
//       }

//       final batches = productMap['stock_batches'] as List?;
//       if (batches != null && batches.isNotEmpty) {
//         productMap['purchase_date'] = batches[0]['purchase_date'];
//         productMap['expiry_date'] = batches[0]['expiry_date'];
//         productMap['purchase_price'] = batches[0]['purchase_price'];
//       }

//       return ProductModel.fromJson(productMap);
//     }).toList();
//   }

//   void updateMainProductList() {
//     productList.value = [...shopProductList, ...goDownProductList];

//     // 🔥 Hive mein save kar rahe hain taaki next time app khulte hi data mil jaye
//     LocalService.saveProducts(productList);

//     isDataLoading.value = false;
//   }

//   void clear() {
//     searchController.clear();
//     searchText.value = '';
//   }

//   void controllerClear() {
//     addSubtractQty.clear();
//   }

//   void isInventoryScanSelectedValue() async {
//     bool isInventoryScanSelecteds = await retrieveInventoryScan();
//     isInventoryScanSelected.value = isInventoryScanSelecteds;
//   }

//   void searchProduct(String value) {
//     searchText.value = value;
//     searchController.text = searchText.value;
//   }

//   @override
//   void onClose() {
//     tabController?.dispose();
//     super.onClose();
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/gobal_controller.dart'; // 🔥 GlobalStore Sync
import 'package:inventory/helper/logger.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';

class InventoryListController extends GetxController
    with GetSingleTickerProviderStateMixin, CacheManager, LocalService {
  final userId = SupabaseConfig.auth.currentUser?.id;

  // --- Existing Variables ---
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

    // 🔥 GLOBAL STORE LISTENER
    // Jab bhi GlobalStore.allProducts badlega, ye automatic UI refresh karega
    ever(Get.find<GlobalStore>().allProducts, (_) {
      _syncFromGlobalStore();
    });
  }

  @override
  void onReady() {
    fetchAllInventory();
    super.onReady();
  }

  // 🔥 FETCH INVENTORY (Global Store Priority)
  Future<void> fetchAllInventory() async {
    isDataLoading.value = true;
    final globalStore = Get.find<GlobalStore>();

    if (globalStore.allProducts.isNotEmpty) {
      // 1. Agar Global RAM mein data hai toh wahi se uthao
      _syncFromGlobalStore();
    } else {
      // 2. Agar RAM khali hai toh Hive se load karo
      final cachedData = LocalService.getCachedProducts();
      if (cachedData.isNotEmpty) {
        productList.value = cachedData;
        _updateCategorizedLists(cachedData);
      }
    }
    isDataLoading.value = false;
  }

  // 🟢 GLOBAL RAM SE DATA SYNC KARNE KA LOGIC
  void _syncFromGlobalStore() {
    final globalStore = Get.find<GlobalStore>();
    final List<ProductModel> data = List<ProductModel>.from(
      globalStore.allProducts,
    );

    productList.value = data;
    _updateCategorizedLists(data);
    LocalService.saveProducts(data); // Background Cache Update
  }

  // 🟢 TAB LISTS KO SEPARATE KARNA
  void _updateCategorizedLists(List<ProductModel> data) {
    shopProductList.value = data.where((p) => p.location == 'shop').toList();
    goDownProductList.value =
        data.where((p) => p.location == 'godown').toList();
  }

  // --- Existing Helper Functions ---
  void updateMainProductList() {
    productList.value = [...shopProductList, ...goDownProductList];
    LocalService.saveProducts(productList);
    isDataLoading.value = false;
  }

  // Fake Network methods kept for logic consistency
  Future<void> listenShopProducts() async => _syncFromGlobalStore();
  Future<void> listenGodownProducts() async => _syncFromGlobalStore();

  void clear() {
    searchController.clear();
    searchText.value = '';
  }

  void controllerClear() => addSubtractQty.clear();

  Future<void> isInventoryScanSelectedValue() async {
    try {
      bool isInventoryScanSelecteds = await retrieveInventoryScan();
      isInventoryScanSelected.value = isInventoryScanSelecteds;
    } catch (e) {
      AppLogger.error(
        'Failed to load inventory scan setting',
        e,
        'InventoryListController',
      );
      isInventoryScanSelected.value = false;
    }
  }

  void searchProduct(String value) {
    searchText.value = value;
    // searchController.text = value; // Note: UI focus issue handle karne ke liye usually ye nahi karte
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }
}
