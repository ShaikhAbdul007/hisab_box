import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/near_expire_product/model/near_expiry_model.dart';
import 'package:inventory/module/out_of_stock/repo/out_of_stock_repo.dart';

class OutOfStockController extends GetxController with CacheManager {
  OutOfStockRepo outOfStockRepo = OutOfStockRepo();
  RxBool isDataLoading = false.obs;
  RxBool isDeleteLoading = false.obs;
  RxList<NeaExpiryItemData> productList = <NeaExpiryItemData>[].obs;
  RxString searchText = ''.obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    loadOutOfStockProducts();
    super.onInit();
  }

  void clear() {
    searchController.clear();
    searchText.value = '';
  }

  void searchProduct(String value) {
    searchText.value = value;
    searchController.text = searchText.value;
  }

  // 🔥 FLOW: Hive Load -> Supabase Sync -> Hive Update
  Future<void> loadOutOfStockProducts() async {
    isDataLoading.value = productList.isEmpty;

    try {
      var response = await outOfStockRepo.fetchOutOfStockProducts();
      if (response.success == success) {
        productList.value = response.data?.data ?? [];
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
      AppLogger.info(
        ("✅ Out of Stock Synced with Supabase & Hive Updated").toString(),
      );
    } catch (e) {
      AppLogger.info(("🚨 OutOfStock Fetch Error: $e").toString());
      showSnackBar(error: e.toString());
    } finally {
      isDataLoading.value = false;
    }
  }

  Future<void> deactivateSpecificProduct({required String productId}) async {
    isDeleteLoading.value = true;
    final userId = resolveUserId(isDeleteLoading.value);
    if (userId == null) {
      isDeleteLoading.value = false;
      return;
    }
    try {} catch (e) {
      AppLogger.info(("🚨 Deactivate Error: $e").toString());
      showSnackBar(error: e.toString());
    } finally {
      isDeleteLoading.value = false;
    }
  }
}
