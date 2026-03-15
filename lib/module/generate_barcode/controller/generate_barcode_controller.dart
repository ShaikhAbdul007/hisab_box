import 'package:inventory/helper/logger.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/gobal_module/gobal_controller.dart';
import '../../../helper/helper.dart';
import '../../../helper/set_format_date.dart';
import '../../category/model/category_model.dart';
import 'package:get/get.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Mixin
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import 'package:inventory/module/inventory/model/product_model.dart';

class GenerateBarcodeController extends GetxController
    with CacheManager, LocalService {
  final globalStore = Get.find<GlobalStore>();
  RxBool categoryListLoading = false.obs;
  final inventoryScanKey = GlobalKey<FormState>();
  RxBool animalCategoryListLoading = false.obs;
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
  TextEditingController level = TextEditingController();
  TextEditingController rack = TextEditingController();
  TextEditingController productName = TextEditingController();
  TextEditingController looseQuantity = TextEditingController();
  TextEditingController looseSellingPrice = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController animalType = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController purchasePrice = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController barcode = TextEditingController();
  TextEditingController loooseProductName = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController discount = TextEditingController(text: '0');
  TextEditingController purchaseDate = TextEditingController();
  TextEditingController exprieDate = TextEditingController();

  bool isLoose = false;
  RxBool isSaveLoading = false.obs;
  RxBool isFlavorAndWeightNotRequired = true.obs;
  RxString dayDate = ''.obs;

  @override
  void onInit() {
    setBarcode();
    dayDate.value = setFormateDate();
    getCategoryDataAndAnimalData();
    super.onInit();
  }

  void setBarcode() {
    barcode.text = generateBarcodeNo();
  }

  @override
  void dispose() {
    barcode.dispose();
    productName.dispose();
    looseQuantity.dispose();
    looseSellingPrice.dispose();
    category.dispose();
    sellingPrice.dispose();
    purchasePrice.dispose();
    flavor.dispose();
    weight.dispose();
    quantity.dispose();
    super.dispose();
  }

  void getCategoryDataAndAnimalData() async {
    await fetchCategories();
    await fetchAnimalCategories();
  }

  void calculatePurchasePrice() {
    if (sellingPrice.text.isNotEmpty) {
      double sellingPrices = double.tryParse(sellingPrice.text) ?? 0;
      double purchasePrices = sellingPrices - (sellingPrices * 0.20);
      purchasePrice.text = purchasePrices.toStringAsFixed(2);
    }
  }

  Future<void> fetchCategories() async {
    categoryListLoading.value = true;
    final cached = LocalService.getCachedCategories();
    if (cached.isNotEmpty) {
      categoryList.value = cached;
      categoryListLoading.value = false;
    }
    final userId = resolveUserId(categoryListLoading.value);
    if (userId == null) {
      categoryListLoading.value = false;
      return;
    }
    try {
      final response = await SupabaseConfig.from(
        'categories',
      ).select().eq('user_id', userId);
      final freshData =
          (response as List).map((e) => CategoryModel.fromJson(e)).toList();
      categoryList.value = freshData;
      await LocalService.saveCategories(freshData);
    } catch (e) {
      AppLogger.info(("🚨 Category Error: $e").toString());
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      categoryListLoading.value = false;
    }
  }

  // 🔥 FETCH ANIMAL CATEGORIES
  Future<void> fetchAnimalCategories() async {
    animalCategoryListLoading.value = true;
    final cached = LocalService.getCachedAnimalCategories();
    if (cached.isNotEmpty) {
      animalTypeList.value = cached;
      animalCategoryListLoading.value = false;
    }
    final userId = resolveUserId(animalCategoryListLoading.value);
    if (userId == null) {
      animalCategoryListLoading.value = false;
      return;
    }
    try {
      final response = await SupabaseConfig.from(
        'animal_categories',
      ).select().eq('user_id', userId);
      final freshData =
          (response as List).map((e) => CategoryModel.fromJson(e)).toList();
      animalTypeList.value = freshData;
      await LocalService.saveAnimalCategories(freshData);
    } catch (e) {
      AppLogger.info(("🚨 Animal Error: $e").toString());
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      animalCategoryListLoading.value = false;
    }
  }

  String generateBarcodeNo() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    String timeStr = timestamp.toString();
    String uniqueSuffix = timeStr.substring(timeStr.length - 8);

    int randomExtra = Random().nextInt(90) + 10; // 10 se 99 tak random

    return "HB$uniqueSuffix$randomExtra";
  }

  // --- 3. Save Product (Supabase Insert + Hive Update) ---
  Future<void> saveNewProduct({required String barcode}) async {
    isSaveLoading.value = true;
    final userId = resolveUserId(isSaveLoading.value);
    try {
      if (userId == null) return;
      if (category.text.isEmpty || animalType.text.isEmpty) {
        showMessage(message: "❌ Category aur Animal Type select karein!");
        return;
      }

      await SupabaseConfig.client.rpc(
        'add_new_product_v2',
        params: {
          'p_user_id': userId,
          'p_name': productName.text.trim(),
          'p_category': category.text.trim(),
          'p_animal_type': animalType.text.trim(),
          'p_flavor': flavor.text,
          'p_level': level.text,
          'p_rack': rack.text,
          'p_weight': weight.text,
          'p_is_loose': isLoose,
          'p_barcode': barcode,
          'p_qty': num.tryParse(quantity.text) ?? 0,
          'p_s_price': double.tryParse(sellingPrice.text) ?? 0.0,
          'p_p_price': double.tryParse(purchasePrice.text) ?? 0.0,
          'p_disc_amt': double.tryParse(discount.text) ?? 0.0,
          'p_purchase_date': formatDateForRpc(purchaseDate.text),
          'p_expiry_date': formatDateForRpc(exprieDate.text),
          'p_location':
              location.text.toLowerCase().contains('godown')
                  ? 'godown'
                  : 'shop',
        },
      );
      await globalStore.loadInitialData();
      showMessage(message: "✅ Product Saved!");
      clear();
      // GlobalStore ka realtime sync is naye product ko khud utha lega.
      Get.back(result: true);
    } catch (e) {
      AppLogger.info(("Database Error: $e").toString());
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isSaveLoading.value = false;
    }
  }

  // --- 4. Delete Product (Supabase Delete + Hive Update) ---
  Future<void> deleteProduct(String productId) async {
    try {
      // 1. Supabase se delete karo
      await SupabaseConfig.from('products').delete().eq('id', productId);

      // 2. Hive se delete karo
      List<ProductModel> currentCachedProducts =
          LocalService.getCachedProducts();
      currentCachedProducts.removeWhere((p) => p.id == productId);
      await LocalService.saveProducts(currentCachedProducts);

      showMessage(message: "Product deleted successfully");
    } catch (e) {
      AppLogger.info(("🚨 Delete Error: $e").toString());
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    }
  }

  void clear() {
    barcode.clear();
    productName.clear();
    looseQuantity.clear();
    looseSellingPrice.clear();
    category.clear();
    sellingPrice.clear();
    purchasePrice.clear();
    flavor.clear();
    weight.clear();
    quantity.clear();
  }
}
