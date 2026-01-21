import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import '../model/sell_model.dart';

class SellController extends GetxController with CacheManager {
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

  void setSellList() async {
    final today = dayDate.value;

    // 1️⃣ Cache check
    final cache = getTodaySellCache();
    if (cache != null && cache['date'] == today) {
      sellsList.value =
          (cache['sells'] as List).map((e) => SaleModel.fromMap(e)).toList();
      return;
    }

    // 2️⃣ Firebase fallback
    final data = await fetchSales();
    sellsList.value = data;

    // 3️⃣ Cache save
    saveTodaySellCache(date: today, sells: data);
  }

  Future<List<SaleModel>> fetchSales() async {
    isSellListLoading.value = true;
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return [];

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('sales')
              .where('soldAt', isEqualTo: dayDate.value)
              .get();

      final Map<String, SaleModel> salesByBarcode = {};

      for (var doc in snapshot.docs) {
        final sale = SaleModel.fromMap(doc.data());
        final barcode = sale.barcode;

        if (salesByBarcode.containsKey(barcode)) {
          final existing = salesByBarcode[barcode]!;
          salesByBarcode[barcode] = SaleModel(
            sellingPrice: existing.sellingPrice,
            animalType: existing.animalType,
            barcode: existing.barcode,
            quantity: existing.quantity + sale.quantity,
            soldAt: existing.soldAt,
            name: existing.name,
            category: existing.category,
            time: existing.time,
            weight: existing.weight,
            amount: existing.amount,
            flavor: existing.flavor,
            discountPercentage: existing.discountPercentage,
            amountAfterDiscount: existing.amountAfterDiscount,
          );
        } else {
          salesByBarcode[barcode] = sale;
        }
      }

      return salesByBarcode.values.toList();
    } finally {
      isSellListLoading.value = false;
    }
  }
}
