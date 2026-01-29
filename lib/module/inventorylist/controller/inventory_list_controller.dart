import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';

class InventoryListController extends GetxController
    with GetSingleTickerProviderStateMixin, CacheManager {
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

  // ================================
  // 🔥 SHOP PRODUCTS (SUPABASE)
  // ================================
  void listenShopProducts() async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;

    isDataLoading.value = true;

    final response = await SupabaseConfig.from('product_stock')
        .select('''
          quantity,
          location,
          is_active,
          stock_type,
          selling_price,
          products (
            id,
            name,
            category,
            animal_type,
            is_loose_category,
            is_flavor_and_weight_not_required
          )
        ''')
        .eq('user_id', userId)
        .eq('location', 'shop')
        .eq('is_active', true);

    final shopList =
        (response as List).map((e) {
          final product = Map<String, dynamic>.from(e['products']);

          product['quantity'] = e['quantity'];
          product['location'] = e['location'];
          product['is_active'] = e['is_active'];
          product['selling_price'] = e['selling_price'];

          // packet / loose mapping
          product['is_loose'] = e['stock_type'] == 'loose';

          return ProductModel.fromJson(product);
        }).toList();

    saveProductList(shopList);
    shopProductList.value = shopList;

    updateMainProductList();
    recalculateInventoryDashboardOnly();
  }

  // ================================
  // 🔥 GODOWN PRODUCTS (SUPABASE)
  // ================================
  void listenGodownProducts() async {
    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) return;

    final response = await SupabaseConfig.from('product_stock')
        .select('''
          quantity,
          location,
          is_active,
          stock_type,
          selling_price,
          products (
            id,
            name,
            category,
            animal_type,
            is_loose_category,
            is_flavor_and_weight_not_required
          )
        ''')
        .eq('user_id', userId)
        .eq('location', 'godown')
        .eq('is_active', true);

    final godownList =
        (response as List).map((e) {
          final product = Map<String, dynamic>.from(e['products']);

          product['quantity'] = e['quantity'];
          product['location'] = e['location'];
          product['is_active'] = e['is_active'];
          product['selling_price'] = e['selling_price'];

          product['is_loose'] = e['stock_type'] == 'loose';

          return ProductModel.fromJson(product);
        }).toList();

    saveGodownProductList(godownList);
    goDownProductList.value = godownList;

    updateMainProductList();
    recalculateInventoryDashboardOnly();
  }

  // ================================
  // 🔥 MERGE SHOP + GODOWN
  // ================================
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
    super.onClose();
  }
}


// class InventoryListController extends GetxController
//     with GetSingleTickerProviderStateMixin, CacheManager {
//   // 🔥 FIREBASE REMOVED
//   // final FirebaseAuth _auth = FirebaseAuth.instance;

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

//   // 🔥 FIREBASE STREAMS REMOVED (names kept, unused)

//   @override
//   void onInit() {
//     isInventoryScanSelectedValue();
//     tabController = TabController(length: 2, vsync: this);
//     super.onInit();
//   }

//   @override
//   void onReady() {
//     // 🔥 MANUAL FETCH (instead of realtime listeners)
//     listenShopProducts();
//     listenGodownProducts();
//     super.onReady();
//   }

//   // ================================
//   // 🔥 SHOP PRODUCTS (SUPABASE)
//   // ================================
//   void listenShopProducts() async {
//     final userId = SupabaseConfig.auth.currentUser?.id;
//     if (userId == null) return;

//     isDataLoading.value = true;

//     final response = await SupabaseConfig.from('products')
//         .select()
//         .eq('user_id', userId)
//         .eq('location', 'shop')
//         .eq('is_active', true);

//     final shopList =
//         (response as List).map((e) => ProductModel.fromJson(e)).toList();

//     // 🔥 Cache shop products
//     saveProductList(shopList);

//     // 🔥 Update shop list
//     shopProductList.value = shopList;

//     // 🔥 Merge lists
//     updateMainProductList();

//     // 🔥 Dashboard recalculation
//     recalculateInventoryDashboardOnly();
//   }

//   // ================================
//   // 🔥 GODOWN PRODUCTS (SUPABASE)
//   // ================================
//   void listenGodownProducts() async {
//     final userId = SupabaseConfig.auth.currentUser?.id;
//     if (userId == null) return;

//     final response = await SupabaseConfig.from('products')
//         .select()
//         .eq('user_id', userId)
//         .eq('location', 'godown')
//         .eq('is_active', true);

//     final godownList =
//         (response as List).map((e) => ProductModel.fromJson(e)).toList();

//     // 🔥 Cache godown products
//     saveGodownProductList(godownList);

//     // 🔥 Update godown list
//     goDownProductList.value = godownList;

//     // 🔥 Merge lists
//     updateMainProductList();

//     // 🔥 Dashboard recalculation
//     recalculateInventoryDashboardOnly();
//   }

//   // ================================
//   // 🔥 MERGE SHOP + GODOWN
//   // ================================
//   void updateMainProductList() {
//     productList.value = [...shopProductList, ...goDownProductList];
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
//     // 🔥 Streams already null, but cleanup kept

//     super.onClose();
//   }
// }



// class InventoryListController extends GetxController
//     with GetSingleTickerProviderStateMixin, cache.CacheManager {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
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
//   StreamSubscription<QuerySnapshot>? productSub;
//   StreamSubscription<QuerySnapshot>? godownSub; // 🔥 NEW LISTENER
//   StreamSubscription<QuerySnapshot>? looseSub; // 🔥 LOOSE PRODUCTS LISTENER

//   @override
//   void onInit() {
//     isInventoryScanSelectedValue();
//     tabController = TabController(length: 2, vsync: this);
//     super.onInit();
//   }

//   @override
//   void onReady() {
//     listenShopProducts(); // 🔥 REALTIME SHOP
//     listenGodownProducts(); // 🔥 REALTIME GODOWN
//     // listenLooseProducts(); // 🔥 REALTIME LOOSE
//     super.onReady();
//   }

//   void listenShopProducts() {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return;

//     isDataLoading.value = true;

//     productSub = FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .collection('products') // SHOP
//         .where('isActive', isEqualTo: true)
//         .snapshots()
//         .listen((snapshot) {
//           final shopList =
//               snapshot.docs
//                   .map((e) => ProductModel.fromJson(e.data()))
//                   .toList();

//           // 🔥 Cache shop products
//           saveProductList(shopList);

//           // 🔥 Update shop list
//           shopProductList.value = shopList;

//           // 🔥 Merge and update main list
//           updateMainProductList();

//           // 🔥 UPDATE DASHBOARD CACHE
//           recalculateInventoryDashboardOnly();
//         });
//   }

//   void listenGodownProducts() {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return;

//     godownSub = FirebaseFirestore.instance
//         .collection('users')
//         .doc(uid)
//         .collection('godownProducts') // GODOWN
//         .where('isActive', isEqualTo: true)
//         .snapshots()
//         .listen((snapshot) {
//           final godownList =
//               snapshot.docs
//                   .map((e) => ProductModel.fromJson(e.data()))
//                   .toList();

//           // 🔥 Cache godown products
//           saveGodownProductList(godownList);

//           // 🔥 Update godown list
//           goDownProductList.value = godownList;

//           // 🔥 Merge and update main list
//           updateMainProductList();

//           // 🔥 UPDATE DASHBOARD CACHE
//           recalculateInventoryDashboardOnly();
//         });
//   }

//   void updateMainProductList() {
//     // 🔥 Merge shop + godown lists
//     productList.value = [...shopProductList, ...goDownProductList];
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
//     productSub?.cancel();
//     godownSub?.cancel(); // 🔥 CANCEL GODOWN LISTENER
//     looseSub?.cancel(); // 🔥 CANCEL LOOSE LISTENER
//     super.onClose();
//   }
// }

//  void setListAsPerType() {
//     // 🔥 NO NEED TO FILTER - ALREADY SEPARATED
//     // shopProductList and goDownProductList are already updated by listeners
//   }


// void listenLooseProducts() {
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) return;

  //   looseSub = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .collection('looseProducts') // LOOSE
  //       .where('isActive', isEqualTo: true)
  //       .snapshots()
  //       .listen((snapshot) async {
  //         final looseList =
  //             snapshot.docs
  //                 .map((e) => ProductModel.fromJson(e.data()))
  //                 .toList();

  //         // 🔥 Cache loose products (convert to LooseInvetoryModel)
  //         final looseModels =
  //             looseList
  //                 .map(
  //                   (p) => LooseInvetoryModel(
  //                     barcode: p.barcode,
  //                     name: p.name,
  //                     category: p.category,
  //                     animalType: p.animalType,
  //                     quantity: p.quantity?.toInt(),
  //                     purchasePrice: p.purchasePrice,
  //                     sellingPrice: p.sellingPrice,
  //                     weight: p.weight,
  //                     color: p.color,
  //                     level: p.level,
  //                     rack: p.rack,
  //                     location: p.location,
  //                     discount: p.discount,
  //                     isFlavorAndWeightNotRequired:
  //                         p.isFlavorAndWeightNotRequired,
  //                     createdDate: p.createdDate,
  //                     createdTime: p.createdTime,
  //                     updatedDate: p.updatedDate,
  //                     updatedTime: p.updatedTime,
  //                     expireDate: p.expireDate,
  //                     purchaseDate: p.purchaseDate,
  //                     isActive: p.isActive,
  //                     sellType: p.sellType,
  //                   ),
  //                 )
  //                 .toList();

  //         saveLoosedProductList(looseModels);

  //         // 🔥 UPDATE DASHBOARD CACHE
  //         recalculateInventoryDashboardOnly();
  //       });
  // }
