import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/helper/set_format_date.dart';

import '../model/sell_model.dart';

class SellController extends GetxController {
  final _auth = FirebaseAuth.instance;
  RxBool isSellListLoading = false.obs;
  var sellsList = <SaleModel>[].obs;
  RxString dayDate = ''.obs;
  @override
  void onInit() {
    dayDate.value = setFormateDate();
    setSellList();

    super.onInit();
  }

  setSellList() async {
    sellsList.value = await fetchSales();
  }

  Future<List<SaleModel>> fetchSales() async {
    isSellListLoading.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('sales')
            .orderBy('soldAt', descending: true)
            .where('soldAt', isEqualTo: dayDate.value)
            .get();

    final Map<String, SaleModel> salesByBarcode = {};
    for (var doc in snapshot.docs) {
      final sale = SaleModel.fromMap(doc.data());
      final barcode = sale.barcode;
      if (salesByBarcode.containsKey(barcode)) {
        final existingSale = salesByBarcode[barcode]!;
        salesByBarcode[barcode] = SaleModel(
          barcode: existingSale.barcode,
          quantity: (existingSale.quantity) + (sale.quantity),
          soldAt: existingSale.soldAt,
          name: existingSale.name,
          category: existingSale.category,
          time: existingSale.time,
          weight: existingSale.weight,
          amount: existingSale.amount,
          flavor: existingSale.flavor,
          discountPercentage: existingSale.discountPercentage,
          amountAfterDiscount: existingSale.amountAfterDiscount,
        );
        isSellListLoading.value = false;
      } else {
        salesByBarcode[barcode] = sale;
        isSellListLoading.value = false;
      }
    }
    isSellListLoading.value = false;
    return salesByBarcode.values.toList();
  }
}
