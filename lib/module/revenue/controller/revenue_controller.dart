import 'package:inventory/helper/logger.dart';
import 'package:get/get.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/module/gobal_module/gobal_controller.dart';
import '../model/revenue_model.dart';

class RevenueController extends GetxController with LocalService {
  final uid = SupabaseConfig.auth.currentUser?.id;
  final globalStore = Get.find<GlobalStore>();

  // --- EXISTING VARIABLES (NO NAMES CHANGED) ---
  RxBool isRevenueListLoading = false.obs;
  var sellsList = <SellsModel>[].obs;
  RxDouble sellTotalAmount = 0.0.obs;
  RxString dayDate = ''.obs;

  @override
  void onInit() {
    dayDate.value = setFormateDate();

    // 1. Pehle local (Hive) se uthao instant UI ke liye
    loadFromLocal();

    // 2. GlobalStore se sync karo
    setSellList();

    // 3. 🔥 REALTIME SYNC:
    // Jab bhi GlobalStore ki 'allSalesList' update hogi (Naya bill katega),
    // ye screen bina Supabase call kiye apne aap refresh ho jayegi.
    ever(globalStore.allSalesList, (_) => setSellList());

    super.onInit();
  }

  // --- EXISTING LOGIC (OPTIMIZED TO AVOID SUPABASE) ---

  void loadFromLocal() {
    final today = dayDate.value;
    final cachedData = LocalService.getRevenueFromLocal(today);
    if (cachedData.isNotEmpty) {
      sellsList.assignAll(cachedData);
      _calculateTotal();
    }
  }

  void setSellList() async {
    // 🔥 Ab hum fetchRevenueList() ko call nahi kar rahe jo Supabase jaye.
    // Hum GlobalStore se direct data RAM se utha rahe hain.
    final freshData = await fetchRevenueList();

    sellsList.assignAll(freshData);
    _calculateTotal();

    if (freshData.isNotEmpty) {
      // Local cache update kar do taaki agli baar loadFromLocal fast chale
      final today = dayDate.value;
      await LocalService.saveRevenueToLocal(today, freshData);
    }
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var bill in sellsList) {
      total += (bill.finalAmount ?? 0).toDouble();
    }
    sellTotalAmount.value = total;
  }

  // 🔥 OPTIMIZED: Ab ye function network call nahi karta
  Future<List<SellsModel>> fetchRevenueList() async {
    try {
      // Loader sirf tab dikhao agar list ekdum khali ho
      isRevenueListLoading.value = sellsList.isEmpty;

      final selectedDate = dayDate.value;

      final DateTime parsedDate = parseAppDate(selectedDate) ?? DateTime.now();
      final dbData = await globalStore.fetchSalesByDate(parsedDate);
      if (dbData.isNotEmpty) return dbData;

      final filtered =
          globalStore.allSalesList.where((sale) {
            final soldDate = formatDateForUi(sale.soldAt);
            return soldDate == selectedDate;
          }).toList();
      if (filtered.isNotEmpty) return filtered;

      return LocalService.getRevenueFromLocal(selectedDate);
    } catch (e) {
      AppLogger.info(("🚨 Revenue Sync Error: $e").toString());
      return [];
    } finally {
      isRevenueListLoading.value = false;
    }
  }
}
