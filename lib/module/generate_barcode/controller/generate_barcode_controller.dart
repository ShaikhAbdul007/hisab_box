import 'package:flutter/material.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import '../../../helper/helper.dart';
import '../../../helper/set_format_date.dart';
import '../../category/model/category_model.dart';
import 'package:get/get.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Mixin
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/module/inventory/model/product_model.dart';

class GenerateBarcodeController extends GetxController
    with CacheManager, LocalService {
  final userId = SupabaseConfig.auth.currentUser?.id;

  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;

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
    dayDate.value = setFormateDate();
    getCategoryDataAndAnimalData();
    super.onInit();
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

  // --- 1. Categories (Hive Fallback + Supabase Sync) ---
  Future<void> fetchCategories() async {
    // Pehle Hive se show karo
    var localData = LocalService.getCachedCategories();
    if (localData.isNotEmpty) {
      categoryList.value = localData;
    }

    if (userId == null) return;

    try {
      final response = await SupabaseConfig.from(
        'categories',
      ).select('*').eq('user_id', userId!);

      List<CategoryModel> freshData =
          (response as List)
              .map((data) => CategoryModel.fromJson(data))
              .toList();

      categoryList.value = freshData;
      await LocalService.saveCategories(freshData);
    } catch (e) {
      print("🚨 Category Fetch Error: $e");
    }
  }

  // --- 2. Animal Categories (Hive Fallback + Supabase Sync) ---
  Future<void> fetchAnimalCategories() async {
    var localAnimalData = LocalService.getCachedAnimalCategories();
    if (localAnimalData.isNotEmpty) {
      animalTypeList.value = localAnimalData;
    }

    if (userId == null) return;

    try {
      final response = await SupabaseConfig.from(
        'animal_categories',
      ).select('*').eq('user_id', userId!);

      List<CategoryModel> freshAnimalData =
          (response as List)
              .map((data) => CategoryModel.fromJson(data))
              .toList();

      animalTypeList.value = freshAnimalData;
      await LocalService.saveAnimalCategories(freshAnimalData);
    } catch (e) {
      print("🚨 Animal Category Fetch Error: $e");
    }
  }

  // --- 3. Save Product (Supabase Insert + Hive Update) ---
  Future<void> saveProduct() async {
    if (userId == null) return;
    isSaveLoading.value = true;

    try {
      // Map data as per ProductModel
      final Map<String, dynamic> productMap = {
        'user_id': userId,
        'name': productName.text,
        'barcode': barcode.text,
        'selling_price': double.tryParse(sellingPrice.text) ?? 0.0,
        'purchase_price': double.tryParse(purchasePrice.text) ?? 0.0,
        'category': category.text,
        'animal_type': animalType.text,
        'quantity': double.tryParse(quantity.text) ?? 0.0,
        'flavor': flavor.text,
        'weight': weight.text,
        'location': location.text,
        'discount': int.tryParse(discount.text) ?? 0,
        'purchase_date': purchaseDate.text,
        'expire_date': exprieDate.text,
        'is_flavor_weight_not_required': isFlavorAndWeightNotRequired.value,
        'is_loosed': isLoose,
        'shop_type': 'general', // Default or from user profile
        'created_at': DateTime.now().toIso8601String(),
      };

      // 1. Supabase mein data insert karein
      final response =
          await SupabaseConfig.from(
            'products',
          ).insert(productMap).select().single();

      // 2. Local Hive Cache Update
      // Pehle purani list nikaalo
      List<ProductModel> currentCachedProducts =
          LocalService.getCachedProducts();

      // Naya product model banao response se (taaki ID mil jaye)
      ProductModel newProduct = ProductModel.fromJson(response);

      // List mein add karo aur save kardo
      currentCachedProducts.add(newProduct);
      await LocalService.saveProducts(currentCachedProducts);

      showMessage(message: "Product saved successfully!");
      Get.back(); // Form close kardo
    } catch (e) {
      print("🚨 Save Product Error: $e");
      showMessage(message: "Failed to save product: $e");
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
      print("🚨 Delete Error: $e");
      showMessage(message: "Could not delete product");
    }
  }
}
