import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/cache_manager/cache_manager.dart';

import '../../inventory/model/product_model.dart';

class NearExpireProductController extends GetxController with CacheManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxList<ProductModel> nearExpProductList = <ProductModel>[].obs;
  RxBool isDataloading = false.obs;

  @override
  void onInit() {
    getNearExpiryProducts();
    super.onInit();
  }

  Future<void> getNearExpiryProducts() async {
    isDataloading.value = true;

    /// ❌ OLD
    /// FirebaseFirestore.instance.collection('products').get();

    /// ✅ NEW: CACHE ONLY
    final cachedProducts = await retrieveProductList();

    if (cachedProducts.isEmpty) {
      isDataloading.value = false;
      return;
    }

    final today = DateTime.now();
    final threeMonthsLater = DateTime(today.year, today.month + 3, today.day);

    nearExpProductList.value =
        cachedProducts.where((product) {
          if (product.expireDate == null || product.expireDate!.isEmpty) {
            return false;
          }

          try {
            final expiryDate = DateFormat(
              'dd-MM-yyyy',
            ).parse(product.expireDate!);

            return expiryDate.isAfter(today) &&
                expiryDate.isBefore(threeMonthsLater);
          } catch (_) {
            return false;
          }
        }).toList();

    isDataloading.value = false;
  }
}



// Future<void> getNearExpiryProducts() async {
  //   isDataloading.value = true;
  //   try {
  //     final uid = _auth.currentUser?.uid;
  //     if (uid == null) return;

  //     // 1️⃣ Date range
  //     final today = DateTime.now();
  //     final threeMonthsLater = DateTime(today.year, today.month + 3, today.day);

  //     // 2️⃣ Cache-first (IMPORTANT)
  //     List<ProductModel> products = [];

  //     final cachedProducts = await retrieveProductList();
  //     if (cachedProducts.isNotEmpty) {
  //       products = cachedProducts;
  //     } else {
  //       final snapshot =
  //           await FirebaseFirestore.instance
  //               .collection('users')
  //               .doc(uid)
  //               .collection("products")
  //               .get();

  //       products =
  //           snapshot.docs.map((e) => ProductModel.fromJson(e.data())).toList();
  //       saveProductList(products);
  //     }

  //     // 3️⃣ Local expiry filter (SAFE)
  //     nearExpProductList.value =
  //         products.where((product) {
  //           if (product.expireDate == null || product.expireDate!.isEmpty) {
  //             return false;
  //           }

  //           try {
  //             final expiryDate = DateFormat(
  //               'dd-MM-yyyy',
  //             ).parse(product.expireDate!);

  //             return expiryDate.isAfter(today) &&
  //                 expiryDate.isBefore(threeMonthsLater);
  //           } catch (e) {
  //             return false;
  //           }
  //         }).toList();
  //   } finally {
  //     isDataloading.value = false;
  //   }
  // }