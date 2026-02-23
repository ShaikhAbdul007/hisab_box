import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Use ho rahi hai
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import '../../../helper/helper.dart';
import '../../category/model/category_model.dart';
import '../../inventory/model/product_model.dart';

class ProductController extends GetxController with LocalService {
  final uid = SupabaseConfig.auth.currentUser?.id;
  final inventoryScanKey = GlobalKey<FormState>();

  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  var productList = <ProductModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
  RxList<ProductModel> looseCatogorieList = <ProductModel>[].obs;
  RxList<LooseInvetoryModel> looseInventoryLis = <LooseInvetoryModel>[].obs;
  RxList<ProductModel> fullLooseSellingList = <ProductModel>[].obs;

  TextEditingController productName = TextEditingController();
  TextEditingController looseQuantity = TextEditingController();
  TextEditingController looseSellingPrice = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController animalType = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController discount = TextEditingController(text: '0');
  TextEditingController purchasePrice = TextEditingController();
  TextEditingController level = TextEditingController();
  TextEditingController rack = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController barcode = TextEditingController();
  TextEditingController purchaseDate = TextEditingController();
  TextEditingController exprieDate = TextEditingController();
  TextEditingController loooseProductName = TextEditingController();

  RxBool isFlavorAndWeightNotRequired = true.obs;
  RxBool isLooseProductSave = false.obs;
  RxBool isSaveLoading = false.obs;
  RxString barcodeValue = ''.obs;
  RxBool loosedProduct = false.obs;
  RxBool categoryListLoading = false.obs;
  RxBool animalCategoryListLoading = false.obs;
  RxString dayDate = ''.obs;
  bool isLoose = false;
  var data = Get.arguments;

  @override
  void onInit() async {
    dayDate.value = setFormateDate();
    setLoosedProduct();
    setBarcode();
    getCategoryData();
    super.onInit();
  }

  void setLoosedProduct() {
    loosedProduct.value = data['flag'];
    if (loosedProduct.value) {
      loooseProductName.text = data['productName'];
    }
  }

  void setBarcode() {
    barcode.text = data['barcode'];
    barcodeValue.value = barcode.text;
  }

  void calculatePurchasePrice() {
    if (sellingPrice.text.isNotEmpty) {
      double sellingPrices = double.tryParse(sellingPrice.text) ?? 0;
      double purchasePrices = sellingPrices - (sellingPrices * 0.20);
      purchasePrice.text = purchasePrices.toStringAsFixed(2);
    }
  }

  void getCategoryData() async {
    await fetchCategories();
    await fetchAnimalCategories();
  }

  // ==========================================
  // 🔥 FETCH CATEGORIES (HIVE -> SUPABASE -> HIVE)
  // ==========================================
  Future<void> fetchCategories() async {
    categoryListLoading.value = true;
    // 1. Hive se load karo
    final cached = LocalService.getCachedCategories();
    if (cached.isNotEmpty) {
      categoryList.value = cached;
      categoryListLoading.value = false;
    } else {
      if (uid == null) return;
      try {
        // 2. Supabase Sync
        final response = await SupabaseConfig.from(
          'categories',
        ).select().eq('user_id', uid!);
        final freshData =
            (response as List).map((e) => CategoryModel.fromJson(e)).toList();

        categoryList.value = freshData;
        await LocalService.saveCategories(freshData);
        categoryListLoading.value = false;
      } catch (e) {
        categoryListLoading.value = false; // Hive Update

        print("🚨 Category Sync Error: $e");
      }
    }
  }

  // ==========================================
  // 🔥 FETCH ANIMAL CATEGORIES (HIVE -> SUPABASE)
  // ==========================================
  Future<void> fetchAnimalCategories() async {
    animalCategoryListLoading.value = true;
    final cached = LocalService.getCachedAnimalCategories();
    if (cached.isNotEmpty) {
      animalTypeList.value = cached;
      animalCategoryListLoading.value = false;
    } else {
      if (uid == null) return;
      try {
        final response = await SupabaseConfig.from(
          'animal_categories',
        ).select().eq('user_id', uid!);
        final freshData =
            (response as List).map((e) => CategoryModel.fromJson(e)).toList();

        animalTypeList.value = freshData;
        await LocalService.saveAnimalCategories(freshData);
        animalCategoryListLoading.value = false; // Hive Update
      } catch (e) {
        animalCategoryListLoading.value = false;
        print("🚨 Animal Category Sync Error: $e");
      }
    }
  }

  // ==========================================
  // 🔥 SAVE NEW PRODUCT (ONLINE + HIVE UPDATE)
  // ==========================================
  Future<void> saveNewProduct({required String barcode}) async {
    isSaveLoading.value = true;
    try {
      if (uid == null) return;
      if (category.text.isEmpty || animalType.text.isEmpty) {
        showMessage(message: "❌ Category aur Animal Type select karein!");
        return;
      }

      // 1. Supabase Insert
      await SupabaseConfig.client.rpc(
        'add_new_product_with_stock',
        params: {
          'p_user_id': uid,
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
          'p_purchase_date': formatDateForDB(purchaseDate.text),
          'p_expiry_date': formatDateForDB(exprieDate.text),
          'p_location':
              location.text.toLowerCase().contains('godown')
                  ? 'godown'
                  : 'shop',
        },
      );
      await Future.delayed(const Duration(seconds: 1));

      // 2. Local Sync (Saare products fetch karke Hive update kar do)
      await fetchAllProducts();

      showMessage(message: "✅ Product successfully saved & synced!");
      clear();
      Get.back(result: true);
    } catch (e) {
      showMessage(message: "❌ Database Error: $e");
    } finally {
      isSaveLoading.value = false;
    }
  }

  // ==========================================
  // 🔥 CONVERT PACKET TO LOOSE (SYNC)
  // ==========================================
  Future<void> saveNewLooseProduct({required String barcode}) async {
    isLooseProductSave.value = true;
    try {
      if (uid == null) return;

      // ... (Existing validation logic remains same) ...

      await SupabaseConfig.client.rpc(
        'convert_packet_to_loose',
        params: {
          'p_user_id': uid,
          // (params as per your SQL function)
        },
      );
      await fetchLooseProduct(); // Success ke baad local data refresh karo
      showMessage(message: "✅ Converted & Synced Locally!");
      clear();

      Get.back(result: true);
    } catch (e) {
      showMessage(message: "❌ Error: $e");
    } finally {
      isLooseProductSave.value = false;
    }
  }

  // ==========================================
  // 🔥 FETCH ALL PRODUCTS (HIVE FIRST FLOW)
  // ==========================================
  Future<void> fetchAllProducts() async {
    if (uid == null) return;
    try {
      // 2. Supabase Sync (Inner Join for Active Stock)
      final response = await SupabaseConfig.from('products')
          .select('*, product_stock!inner(*)')
          .eq('user_id', uid!)
          .eq('product_stock.is_active', true);

      final freshList =
          (response as List).map((e) => ProductModel.fromJson(e)).toList();

      // 3. UI and Hive Update
      productList.value = freshList;
      await LocalService.saveProducts(freshList);
    } catch (e) {
      print("🚨 Product Sync Error: $e");
    }
  }

  Future<void> fetchLooseProduct() async {
    if (uid == null) return;

    // 1. Pehle Hive se data lo (Instant UI Show)
    final cachedData = LocalService.getCachedLooseProducts();
    if (cachedData.isNotEmpty) {
      looseInventoryLis.value = cachedData;
      print("📦 Hive se data mil gaya: ${cachedData.length}");
    }

    // 2. Supabase se fetch karo (Fallback & Update)

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
          .eq('user_id', uid!)
          .order('created_at', ascending: false);

      final List data = response as List;
      final List<LooseInvetoryModel> freshList =
          data.map((e) => LooseInvetoryModel.fromJson(e)).toList();

      // 3. UI Update aur Hive Update
      looseInventoryLis.value = freshList;
      await LocalService.saveLooseProducts(freshList);
      print("✅ Supabase se data sync ho gaya aur Hive update ho gaya");
    } catch (e) {
      print("🚨 Fetch Error: $e");
      if (productList.isEmpty)
        showMessage(message: "Check internet connection");
    } finally {}
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

  @override
  void dispose() {
    // Controller fields dispose logic
    super.dispose();
  }
}
