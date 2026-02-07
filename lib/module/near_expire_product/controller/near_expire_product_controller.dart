import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/supabase_db/supabase_client.dart';

import '../../inventory/model/product_model.dart';

class NearExpireProductController extends GetxController with CacheManager {
  final String? uid = SupabaseConfig.auth.currentUser?.id;
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
      final List<ProductModel> cachedProducts = await retrieveProductList();

      if (cachedProducts.isEmpty) {
        nearExpProductList.clear();
        return;
      }

      // 💡 Time ko zero kar rahe hain taaki sirf Date compare ho (Midnight normalization)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final threeMonthsFromNow = today.add(const Duration(days: 90));

      List<ProductModel> filteredList =
          cachedProducts.where((product) {
            if (product.expireDate == null || product.expireDate!.isEmpty) {
              return false;
            }

            try {
              DateTime expiryDate = _parseDate(product.expireDate!);

              // ✅ LOGIC: Expiry date aaj ho ya aaj ke baad, PAR 3 mahine ke andar
              // isAtSameMomentAs use kiya hai taaki aaj expire hone wale bhi dikhein
              bool isExpireTodayOrAfter =
                  expiryDate.isAtSameMomentAs(today) ||
                  expiryDate.isAfter(today);
              bool isWithinThreeMonths =
                  expiryDate.isBefore(threeMonthsFromNow) ||
                  expiryDate.isAtSameMomentAs(threeMonthsFromNow);

              return isExpireTodayOrAfter && isWithinThreeMonths;
            } catch (e) {
              return false;
            }
          }).toList();

      // 3. Sorting
      filteredList.sort((a, b) {
        DateTime dateA = _parseDate(a.expireDate!);
        DateTime dateB = _parseDate(b.expireDate!);
        return dateA.compareTo(dateB);
      });

      nearExpProductList.value = filteredList;
      print("✅ Near Expiry Products Found: ${nearExpProductList.length}");
    } catch (e) {
      print("🚨 Error: $e");
    } finally {
      isDataloading.value = false;
    }
  }

  // Helper method sorting ke liye
  DateTime _parseDate(String dateStr) {
    try {
      if (dateStr.split('-')[0].length == 4) return DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').parse(dateStr);
    } catch (_) {
      return DateTime(2099); // Fallback for sorting
    }
  }
}
