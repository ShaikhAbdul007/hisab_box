import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/set_format_date.dart';

import '../../inventory/model/product_model.dart';

class NearExpireProductController extends GetxController {
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
    try {
      final uid = _auth.currentUser?.uid;
      final now = setFormateDate();
      // final threeMonthsLater = DateTime(now.year, now.month + 3, now.day);

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection("products")
              .where("exprieDate", isGreaterThan: now)
              .get();
      nearExpProductList.value =
          snapshot.docs.map((e) => ProductModel.fromJson(e.data())).toList();
    } finally {
      isDataloading.value = false;
    }
  }
}
