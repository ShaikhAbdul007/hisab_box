import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Mixin
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import '../model/sell_model.dart';

class SellController extends GetxController with CacheManager, LocalService {
  // Purane variable names same rakhe hain
  final userId = SupabaseConfig.auth.currentUser?.id;
  RxBool isSellListLoading = false.obs;
  var sellsList = <SaleModel>[].obs;
  RxString dayDate = ''.obs;

  @override
  void onInit() {
    dayDate.value = setFormateDate();
    setSellList();
    super.onInit();
  }

  // ==========================================
  // 🔥 SET SELL LIST (HIVE + FALLBACK)
  // ==========================================
  void setSellList() async {
    final today = dayDate.value;

    // 1️⃣ Hive Cache Check (Custom local function)
    final cacheData = LocalService.getTodaySales(today);
    if (cacheData.isNotEmpty) {
      sellsList.value = cacheData;
      print("📦 Sales loaded from Hive");
    }

    // 2️⃣ Supabase Fallback (Background fetch for sync)
    final data = await fetchSales();

    if (data.isNotEmpty) {
      sellsList.value = data;
      // 3️⃣ Cache save (Update Hive)
      await LocalService.saveTodaySales(today, data);
    }
  }

  // ==========================================
  // 🔥 FETCH SALES (SUPABASE + GROUPING LOGIC)
  // ==========================================
  Future<List<SaleModel>> fetchSales() async {
    isSellListLoading.value = true;
    try {
      if (userId == null) return [];

      // Supabase se aaj ki sales uthao
      final response = await SupabaseConfig.from(
        'sales',
      ).select().eq('user_id', userId!).eq('soldAt', dayDate.value);

      final List rawData = response as List;
      final Map<String, SaleModel> salesByBarcode = {};

      for (var item in rawData) {
        final sale = SaleModel.fromMap(item);
        final barcode = sale.barcode;

        if (salesByBarcode.containsKey(barcode)) {
          final existing = salesByBarcode[barcode]!;
          // Grouping logic (Quantity sum karna) jaisa aapne pucha tha
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
    } catch (e) {
      print("🚨 Fetch Sales Error: $e");
      return [];
    } finally {
      isSellListLoading.value = false;
    }
  }
}
