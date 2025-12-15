import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../inventory/model/product_model.dart';

class OutOfStockController extends GetxController {
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
    final uid = _auth.currentUser?.uid;
    final productSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('products')
            .where('quantity', isEqualTo: 0)
            .get();
    productList.value =
        productSnapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data()))
            .toList();
    isDataLoading.value = false;
  }
}
