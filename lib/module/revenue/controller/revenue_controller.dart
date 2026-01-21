import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import '../../../helper/helper.dart';
import '../model/revenue_model.dart';

class RevenueController extends GetxController with CacheManager {
  final _auth = FirebaseAuth.instance;
  RxBool isRevenueListLoading = false.obs;
  var sellsList = <SellsModel>[].obs;
  RxDouble sellTotalAmount = 0.0.obs;
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
    final cache = getTodayRevenueCache();
    if (cache != null && cache['date'] == today) {
      sellsList.value =
          (cache['sells'] as List).map((e) => SellsModel.fromJson(e)).toList();

      _calculateTotal();
      return;
    }

    // 2️⃣ Firebase fallback
    final data = await fetchRevenueList();
    sellsList.value = data;

    // 3️⃣ Cache save
    saveTodayRevenueCache(date: today, sells: data);

    _calculateTotal();
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var bill in sellsList) {
      total += (bill.finalAmount ?? 0).toDouble();
    }
    sellTotalAmount.value = total;
  }

  Future<List<SellsModel>> fetchRevenueList() async {
    try {
      isRevenueListLoading.value = true;
      final uid = _auth.currentUser?.uid;
      if (uid == null) return [];
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('sales')
              .where('soldAt', isEqualTo: dayDate.value)
              .get();
      final List<SellsModel> bills =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return SellsModel.fromJson(data);
          }).toList();
      customMessageOrErrorPrint(
        message: '✅ Total Bills Fetched: ${bills.length}',
      );
      if (bills.isNotEmpty) {
        customMessageOrErrorPrint(
          message:
              'First Bill: ${bills.first.billNo} — ₹${bills.first.finalAmount}',
        );
      }
      customMessageOrErrorPrint(message: bills);
      return bills;
    } catch (e) {
      showMessage(message: "❌ Error fetching revenue: ${e.toString()}");
      return [];
    } finally {
      isRevenueListLoading.value = false;
    }
  }
}
