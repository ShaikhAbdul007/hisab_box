import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/set_format_date.dart';

import '../../sell/model/sell_model.dart';

class RevenueController extends GetxController {
  final _auth = FirebaseAuth.instance;
  RxBool isRevenueListLoading = false.obs;
  var sellsList = <SaleModel>[].obs;

  @override
  void onInit() {
    setSellList();
    super.onInit();
  }

  setSellList() async {
    sellsList.value = await fetchRevenue();
  }

  Future<List<SaleModel>> fetchRevenue() async {
    isRevenueListLoading.value = true;
    final uid = _auth.currentUser?.uid;
    final today = setFormateDate();
    if (uid == null) return [];

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('sales')
            .orderBy('soldAt', descending: true)
            .where('soldAt', isEqualTo: today)
            .get();
    isRevenueListLoading.value = false;
    return snapshot.docs.map((doc) {
      return SaleModel.fromMap(doc.data());
    }).toList();
  }
}
