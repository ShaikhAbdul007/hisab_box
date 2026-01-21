import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';

import '../../inventory/model/product_model.dart';

class OutOfStockController extends GetxController with CacheManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxBool isDataLoading = false.obs;
  var productList = <ProductModel>[].obs;
  RxString searchText = ''.obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    fetchAllProducts();
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

  Future<void> fetchAllProducts() async {
    isDataLoading.value = true;

    // 1️⃣ Cache-first
    final cachedProducts = await retrieveProductList();

    if (cachedProducts.isNotEmpty) {
      productList.value =
          cachedProducts.where((p) => (p.quantity ?? 0) == 0).toList();

      isDataLoading.value = false;
      return;
    }

    // 2️⃣ Firebase fallback (only once)
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      isDataLoading.value = false;
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('products')
            .where('quantity', isEqualTo: 0)
            .where('isActive', isEqualTo: true)
            .get();

    productList.value =
        snapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();

    isDataLoading.value = false;
  }
}
