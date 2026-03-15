import 'package:inventory/helper/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/gobal_module/gobal_controller.dart'; // 🔥 GlobalStore Reference
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import 'package:inventory/helper/helper.dart';
import '../../loose_category/model/loose_category_model.dart';

class LooseController extends GetxController with CacheManager, LocalService {
  // --- Text Controllers ---
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController updateQuantity = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController addSubtractQty = TextEditingController();
  TextEditingController newSellingPrice = TextEditingController();
  TextEditingController name = TextEditingController();

  // --- Observables & States ---
  RxBool isDataLoading = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool isInventoryScanSelected = false.obs;
  var productList = <LooseInvetoryModel>[].obs;
  String? id;
  RxList<LooseCategoryModel> looseCategoryModelList =
      <LooseCategoryModel>[].obs;
  RxString searchText = ''.obs;

  // --- Dependencies ---
  final globalStore = Get.find<GlobalStore>(); // 🔥 GlobalStore Instance

  @override
  void onInit() {
    fetchLosseList();

    // 🔥 Realtime Listener: Jab bhi GlobalStore mein loose data badlega, UI update ho jayegi
    ever(globalStore.allLooseProducts, (List<LooseInvetoryModel> updatedList) {
      productList.assignAll(updatedList);
      productList.refresh();
    });

    super.onInit();
  }

  void fetchLosseList() async {
    await fetchLooseProduct();
  }

  // 🔥 FLOW: Hive (Instant) -> Supabase (Network Update) -> GlobalStore & Hive Sync
  Future<void> fetchLooseProduct() async {
    final userId = resolveUserId(isDataLoading.value);
    if (userId == null) return;

    // 1. Pehle Hive se data lo (Instant UI)
    final cachedData = LocalService.getCachedLooseProducts();
    if (cachedData.isNotEmpty) {
      productList.assignAll(cachedData);
      AppLogger.info(
        ("📦 Hive se data mil gaya: ${cachedData.length}").toString(),
      );
    }

    // 2. Loading handle karo (Sirf agar cache khali ho)
    isDataLoading.value = productList.isEmpty;

    try {
      final response = await SupabaseConfig.from('loose_stocks')
          .select('''
          id, quantity, selling_price, product_id, user_id, created_at, updated_at,
          products!fk_loose_stocks_products (
            id, name, flavour, weight, rack, level,
            is_loose_category, is_flavor_and_weight_not_required,
            categories:category (id, name), 
            animals:animal_type (id, name),
            product_barcodes!fk_product_barcodes_products (barcode),
            product_stock!fk_product_stock_products (location, stock_type, is_active),
            stock_batches (purchase_date, expiry_date, purchase_price, location, stock_type)
          )
        ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List data = response as List;
      final List<LooseInvetoryModel> freshList =
          data.map((e) => LooseInvetoryModel.fromJson(e)).toList();

      // 3. UI, Hive aur GlobalStore ko Sync karo
      productList.assignAll(freshList);
      await LocalService.saveLooseProducts(freshList);
      globalStore.allLooseProducts.assignAll(freshList); // 🔥 Sync to RAM

      AppLogger.info(
        ("✅ Supabase sync complete (Hive & GlobalStore updated)").toString(),
      );
    } catch (e) {
      AppLogger.info(("🚨 Fetch Error: $e").toString());
      if (productList.isEmpty) {
        showMessage(message: SupabaseErrorHandler.getMessage(e));
      }
    } finally {
      isDataLoading.value = false;
    }
  }

  void qtyClear() {
    addSubtractQty.clear();
  }

  void searchProduct(String value) {
    searchText.value = value;
    searchController.text = searchText.value;
  }

  void setQuantitydata(int index) {
    sellingPrice.text = productList[index].sellingPrice.toString();
    updateQuantity.text = productList[index].quantity.toString();
  }

  void clear() {
    quantity.clear();
    amount.clear();
  }
}



// // 🔥 UPDATE: Supabase Update -> Refresh Everything
  // void updateProductQuantity({
  //   required String barcode,
  //   required bool add,
  // }) async {
  //   if (userId == null) return;
  //   isSaveLoading.value = true;
  //   try {
  //     // Pehle current quantity fetch karo
  //     final response =
  //         await SupabaseConfig.from(
  //               'loose_stocks',
  //             ) // Fixed: logic for loose_stocks
  //             .select('quantity')
  //             .eq('product_id', barcode)
  //             .eq('user_id', userId!)
  //             .maybeSingle();

  //     if (response != null) {
  //       final num prevQty = response['quantity'] ?? 0;
  //       final num newQtyInput = num.tryParse(addSubtractQty.text) ?? 0;
  //       final double sPrice = double.tryParse(sellingPrice.text) ?? 0.0;
  //       final num finalQty =
  //           add ? prevQty + newQtyInput : prevQty - newQtyInput;

  //       // Cloud Update
  //       await SupabaseConfig.from('loose_stocks')
  //           .update({'quantity': finalQty, 'selling_price': sPrice})
  //           .eq('product_id', barcode)
  //           .eq('user_id', userId!);

  //       Get.back();
  //       qtyClear();
  //       showMessage(message: '✅ Quantity updated successfully.');

  //       // Refresh flow (Auto syncs Hive and GlobalStore)
  //       await fetchLooseProduct();
  //     }
  //   } catch (e) {
  //     print("🚨 Update Error: $e");
  //     showMessage(message: "Update failed: No Internet");
  //   } finally {
  //     isSaveLoading.value = false;
  //   }
  // }
