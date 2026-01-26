import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart' as cache;
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';

class InventoryListController extends GetxController
    with GetSingleTickerProviderStateMixin, cache.CacheManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
  StreamSubscription<QuerySnapshot>? productSub;
  StreamSubscription<QuerySnapshot>? godownSub; // 🔥 NEW LISTENER
  StreamSubscription<QuerySnapshot>? looseSub; // 🔥 LOOSE PRODUCTS LISTENER

  @override
  void onInit() {
    isInventoryScanSelectedValue();
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
  }

  @override
  void onReady() {
    listenShopProducts(); // 🔥 REALTIME SHOP
    listenGodownProducts(); // 🔥 REALTIME GODOWN
    // listenLooseProducts(); // 🔥 REALTIME LOOSE
    super.onReady();
  }

  void listenShopProducts() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    isDataLoading.value = true;

    productSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('products') // SHOP
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          final shopList =
              snapshot.docs
                  .map((e) => ProductModel.fromJson(e.data()))
                  .toList();

          // 🔥 Cache shop products
          saveProductList(shopList);

          // 🔥 Update shop list
          shopProductList.value = shopList;

          // 🔥 Merge and update main list
          updateMainProductList();

          // 🔥 UPDATE DASHBOARD CACHE
          recalculateInventoryDashboardOnly();
        });
  }

  void listenGodownProducts() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    godownSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('godownProducts') // GODOWN
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          final godownList =
              snapshot.docs
                  .map((e) => ProductModel.fromJson(e.data()))
                  .toList();

          // 🔥 Cache godown products
          saveGodownProductList(godownList);

          // 🔥 Update godown list
          goDownProductList.value = godownList;

          // 🔥 Merge and update main list
          updateMainProductList();

          // 🔥 UPDATE DASHBOARD CACHE
          recalculateInventoryDashboardOnly();
        });
  }

  void updateMainProductList() {
    // 🔥 Merge shop + godown lists
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
    productSub?.cancel();
    godownSub?.cancel(); // 🔥 CANCEL GODOWN LISTENER
    looseSub?.cancel(); // 🔥 CANCEL LOOSE LISTENER
    super.onClose();
  }
}

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
