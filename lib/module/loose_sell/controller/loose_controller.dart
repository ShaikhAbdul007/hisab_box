import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/gobal_module/gobal_controller.dart'; // 🔥 GlobalStore Reference
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/module/loose_sell/repo/loose_repo.dart';
import 'package:inventory/helper/helper.dart';

class LooseController extends GetxController with CacheManager {
  LoosedProductRepo loosedProductRepo = LoosedProductRepo();
  TextEditingController searchController = TextEditingController();
  // --- Text Controllers ---
  // TextEditingController sellingPrice = TextEditingController();
  // TextEditingController amount = TextEditingController();
  // TextEditingController quantity = TextEditingController();
  // TextEditingController updateQuantity = TextEditingController();

  // TextEditingController addSubtractQty = TextEditingController();
  // TextEditingController newSellingPrice = TextEditingController();
  // TextEditingController name = TextEditingController();
  // --- Observables & States ---
  RxBool isDataLoading = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool isInventoryScanSelected = false.obs;
  String? id;
  RxList<InventoryItem> looseCategoryModelList = <InventoryItem>[].obs;
  RxString searchText = ''.obs;

  // --- Dependencies ---

  @override
  void onInit() {
    fetchLooseList();
    super.onInit();
  }

  void fetchLooseList() async {
    await fetchLooseProduct();
  }

  Future<void> fetchLooseProduct() async {
    isDataLoading.value = true;
    try {
      var response = await loosedProductRepo.getLoosedProductData();
      if (response.success == success) {
        looseCategoryModelList.value = response.data?.data ?? [];
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info(("🚨 Fetch Error: $e").toString());
      showSnackBar(error: e.toString());
    } finally {
      isDataLoading.value = false;
    }
  }

  // void qtyClear() {
  //   addSubtractQty.clear();
  // }

  void searchProduct(String value) {
    searchText.value = value;
    searchController.text = searchText.value;
  }

  void clear() {
    // quantity.clear();
    // amount.clear();
  }
}
