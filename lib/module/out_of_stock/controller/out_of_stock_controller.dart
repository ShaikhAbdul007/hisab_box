import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/set_format_date.dart';

import '../../inventory/model/product_model.dart';

class OutOfStockController extends GetxController with CacheManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxBool isDataLoading = false.obs;
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
    isDataLoading.value = true;

    /// ❌ OLD
    /// Firebase query with .get()

    /// ✅ NEW: CACHE FILTER
    final cachedProducts = await retrieveProductList();
    final goDownCachedProducts = retrieveGodownProductList();

    var tempProductList =
        cachedProducts.where((p) => (p.quantity ?? 0) == 0).toList();
    var tempGoDownProductList =
        goDownCachedProducts.where((p) => (p.quantity ?? 0) == 0).toList();
    productList.value = [...tempGoDownProductList, ...tempProductList];
    isDataLoading.value = false;
  }

  Future<void> markProductInactive({required ProductModel product}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    isDataLoading.value = true;
    List<ProductModel> tempUpdatedShop = [];
    List<ProductModel> tempUpdatedGodown = [];

    try {
      // 1️⃣ Decide collection based on location
      final String collectionName =
          (product.location ?? '').toLowerCase() == 'godown'
              ? 'godownProducts'
              : 'products';

      // 2️⃣ Firebase WRITE ONLY (no read)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(collectionName)
          .doc(product.barcode)
          .update({
            'isActive': false,
            'updatedDate': setFormateDate(),
            'updatedTime': setFormateDate('hh:mm a'),
          });

      // 3️⃣ Cache update (location aware)
      if (collectionName == 'products') {
        final cachedShop = await retrieveProductList();
        final updatedShop =
            cachedShop.where((p) => p.barcode != product.barcode).toList();

        saveProductList(updatedShop);

        // Refresh out-of-stock UI
        tempUpdatedShop =
            updatedShop.where((p) => (p.quantity ?? 0) == 0).toList();
        saveProductList(updatedShop);
      } else {
        final cachedGodown = retrieveGodownProductList();
        final updatedGodown =
            cachedGodown.where((p) => p.barcode != product.barcode).toList();

        saveGodownProductList(updatedGodown);
        tempUpdatedGodown =
            updatedGodown.where((p) => (p.quantity ?? 0) == 0).toList();
      }

      productList.value = [...tempUpdatedShop, ...tempUpdatedGodown];

      // ❌ No dashboard clear
      // ❌ No firebase read
      // ✅ Cache is source of truth
    } catch (e) {
      showMessage(message: somethingWentMessage);
    } finally {
      isDataLoading.value = false;
    }
  }
}


// Future<void> markProductInactive({required ProductModel product}) async {
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) return;

  //   isDataLoading.value = true;

  //   try {
  //     // 1️⃣ Firebase update (ONLY WRITE)
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(uid)
  //         .collection('products')
  //         .doc(product.barcode) // assuming barcode = docId
  //         .update({'isActive': false, 'updatedDate': setFormateDate()});

  //     // 2️⃣ Cache update (NO FIREBASE READ)
  //     final cachedProducts = await retrieveProductList();

  //     final updatedList =
  //         cachedProducts.where((p) => p.barcode != product.barcode).toList();

  //     saveProductList(updatedList);

  //     // 3️⃣ Recalculate dashboard numbers (NO FIREBASE)
  //     // recalculateDashboardFromCache();

  //     // 4️⃣ Refresh OUT-OF-STOCK UI (remaining products)
  //     productList.value =
  //         updatedList.where((p) => (p.quantity ?? 0) == 0).toList();
  //   } catch (e) {
  //     showMessage(message: somethingWentMessage);
  //   } finally {
  //     isDataLoading.value = false;
  //   }
  // }



//fetchAllProducts();
   
//Future<void> fetchAllProducts() async {
  //   isDataLoading.value = true;

  //   // 1️⃣ Cache-first
  //   final cachedProducts = await retrieveProductList();

  //   if (cachedProducts.isNotEmpty) {
  //     productList.value =
  //         cachedProducts.where((p) => (p.quantity ?? 0) == 0).toList();

  //     isDataLoading.value = false;
  //     return;
  //   }

  //   // 2️⃣ Firebase fallback (only once)
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) {
  //     isDataLoading.value = false;
  //     return;
  //   }

  //   final snapshot =
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(uid)
  //           .collection('products')
  //           .where('quantity', isEqualTo: 0)
  //           .where('isActive', isEqualTo: true)
  //           .get();

  //   productList.value =
  //       snapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();

  //   isDataLoading.value = false;
  // }
