import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import '../../../helper/helper.dart';
import '../../loose_category/model/loose_category_model.dart';
import '../model/loose_model.dart';

class LooseController extends GetxController with CacheManager {
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController updateQuantity = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController addSubtractQty = TextEditingController();
  TextEditingController newSellingPrice = TextEditingController();
  TextEditingController name = TextEditingController();
  RxBool isDataLoading = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool isInventoryScanSelected = false.obs;
  var productList = <LooseInvetoryModel>[].obs;
  String? id;
  RxList<LooseCategoryModel> looseCategoryModelList =
      <LooseCategoryModel>[].obs;
  RxString searchText = ''.obs;

  final userId = SupabaseConfig.auth.currentUser?.id;

  @override
  void onInit() {
    fetchLosseList();
    isInventoryScanSelectedValue();
    super.onInit();
  }

  void fetchLosseList() async {
    await fetchLooseProduct();
  }

  void isInventoryScanSelectedValue() async {
    bool isInventoryScanSelecteds = await retrieveInventoryScan();
    isInventoryScanSelected.value = isInventoryScanSelecteds;
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

  // 🔥 UPDATE QUANTITY (SUPABASE)
  void updateProductQuantity({
    required String barcode,
    required bool add,
  }) async {
    if (userId == null) return;
    isSaveLoading.value = true;
    try {
      // Current stock fetch
      final response =
          await SupabaseConfig.from('product_stock')
              .select('quantity')
              .eq('product_id', barcode)
              .eq('user_id', userId!)
              .maybeSingle();

      if (response != null) {
        final num prevQty = response['quantity'] ?? 0;
        final num newQtyInput = num.tryParse(addSubtractQty.text) ?? 0;
        final double sPrice = double.tryParse(sellingPrice.text) ?? 0.0;
        final num finalQty =
            add ? prevQty + newQtyInput : prevQty - newQtyInput;

        await SupabaseConfig.from('product_stock')
            .update({'quantity': finalQty, 'selling_price': sPrice})
            .eq('product_id', barcode)
            .eq('user_id', userId!);

        removelooseInvetoryKeyModel();
        Get.back();
        qtyClear();
        showMessage(message: '✅ Quantity updated.');
        await fetchLooseProduct();
      }
    } catch (e) {
      print("Update Error: $e");
    } finally {
      isSaveLoading.value = false;
    }
  }

  // 🔥 FETCH LOOSE PRODUCTS (EXPLICIT JOIN)
  Future<void> fetchLooseProduct() async {
    if (userId == null) return;
    isDataLoading.value = true;

    try {
      final response = await SupabaseConfig.from('loose_stocks')
          .select('''
        id,
        quantity,
        selling_price,
        product_id,
        user_id,
        products!inner (
          id, 
          name, 
          flavour, 
          weight,
          rack,
          level,
          is_loose_category,
          categories:category (name), 
          animals:animal_type (name),
          product_stock!product_stock_product_id_fkey (
            location,
            stock_type,
            is_active
          ),
          stock_batches (
            purchase_date,
            expiry_date,
            purchase_price,
            location,
            stock_type
          )
        )
      ''')
          .eq('user_id', userId!)
          .order('created_at', ascending: false);

      final List data = response as List;
      productList.value =
          data.map((e) => LooseInvetoryModel.fromJson(e)).toList();
      saveLoosedProductList(productList);
    } catch (e) {
      print("Final Logic Error: $e");
    } finally {
      isDataLoading.value = false;
    }
  }

  void clear() {
    quantity.clear();
    amount.clear();
  }
}
