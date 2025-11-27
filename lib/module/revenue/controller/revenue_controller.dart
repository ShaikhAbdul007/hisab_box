import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/set_format_date.dart';
import '../../../helper/helper.dart';
import '../model/revenue_model.dart';

class RevenueController extends GetxController {
  final _auth = FirebaseAuth.instance;
  RxBool isRevenueListLoading = false.obs;
  var sellsList = <SellsModel>[].obs;
  RxString dayDate = ''.obs;

  @override
  void onInit() {
    dayDate.value = setFormateDate();
    setSellList();
    super.onInit();
  }

  void setSellList() async {
    sellsList.value = await fetchRevenueList();
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

      isRevenueListLoading.value = false;

      // 🔹 Convert all docs to BillModel
      final List<SellsModel> bills =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return SellsModel.fromJson(data);
          }).toList();

      // Debug logs
      print('✅ Total Bills Fetched: ${bills.length}');
      if (bills.isNotEmpty) {
        print(
          'First Bill: ${bills.first.billNo} — ₹${bills.first.finalAmount}',
        );
      }
      print(bills);

      return bills;
    } catch (e) {
      isRevenueListLoading.value = false;
      showMessage(message: "❌ Error fetching revenue: ${e.toString()}");
      return [];
    }
  }
}
