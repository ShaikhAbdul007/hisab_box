import 'package:get/get.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 Hive Service
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/gobal_controller.dart'; // 🔥 GlobalStore Connection
import '../../inventory/model/product_model.dart';

class NearExpireProductController extends GetxController with LocalService {
  final String? uid = SupabaseConfig.auth.currentUser?.id;
  final globalStore = Get.find<GlobalStore>(); // 🔥 GlobalStore Reference

  RxList<ProductModel> nearExpProductList = <ProductModel>[].obs;
  RxBool isDataloading = false.obs;

  @override
  void onInit() {
    getNearExpiryProducts();

    // 🔥 Live Sync: Agar GlobalStore mein products update honge,
    // toh expiry list khud update ho jayegi.
    ever(globalStore.allProducts, (_) => getNearExpiryProducts());

    super.onInit();
  }

  // 🔥 FLOW: RAM (GlobalStore) -> Filter -> Update UI -> Sync Hive
  Future<void> getNearExpiryProducts() async {
    if (uid == null) return;

    try {
      // 1️⃣ Pehle Hive (Local DB) se data load karo instant view ke liye
      final cachedExpiry = LocalService.getCachedExpiryProducts();
      if (cachedExpiry.isNotEmpty && nearExpProductList.isEmpty) {
        nearExpProductList.value = cachedExpiry;
      }

      // Loader tabhi dikhao jab RAM khali ho (Usually zarurat nahi padegi)
      isDataloading.value = globalStore.allProducts.isEmpty;

      // 2️⃣ STEP 2: GlobalStore (RAM) se data filter karo (NO SUPABASE CALL)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final threeMonthsFromNow = now.add(const Duration(days: 90));

      // Global list se wo products nikalo jinki date 90 din ke andar hai
      List<ProductModel> expiryProducts =
          globalStore.allProducts.where((product) {
            if (product.expireDate == null || product.expireDate!.isEmpty)
              return false;

            DateTime? expiryDate = DateTime.tryParse(product.expireDate!);
            if (expiryDate == null) return false;

            // Filter: Aaj se 90 din ke beech mein
            return expiryDate.isAfter(
                  today.subtract(const Duration(days: 1)),
                ) &&
                expiryDate.isBefore(threeMonthsFromNow);
          }).toList();

      // Sort by date (Sabse pehle expire hone wala upar)
      expiryProducts.sort((a, b) {
        DateTime dateA =
            DateTime.tryParse(a.expireDate ?? '') ?? DateTime(2100);
        DateTime dateB =
            DateTime.tryParse(b.expireDate ?? '') ?? DateTime(2100);
        return dateA.compareTo(dateB);
      });

      // 3️⃣ STEP 3: UI update karo aur Hive mein save karo
      nearExpProductList.assignAll(expiryProducts);
      await LocalService.saveExpiryProducts(expiryProducts);

      print(
        "✅ Expiry List Sync from GlobalStore: ${expiryProducts.length} items",
      );
    } catch (e) {
      print("🚨 Expiry Calculation Error: $e");
    } finally {
      isDataloading.value = false;
    }
  }
}
