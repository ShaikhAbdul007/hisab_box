import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 Hive Service
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import '../../../helper/helper.dart';
import '../../../helper/set_format_date.dart';
import '../../category/model/category_model.dart';
import '../../inventory/model/product_model.dart';

class ProductDetailsController extends GetxController with LocalService {
  final userId = SupabaseConfig.auth.currentUser?.id;

  final inventoryScanKey = GlobalKey<FormState>();
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
  RxList<ProductModel> looseCatogorieList = <ProductModel>[].obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<LooseInvetoryModel> looseInventoryLis = <LooseInvetoryModel>[].obs;
  RxList<ProductModel> fullLooseSellingList = <ProductModel>[].obs;

  TextEditingController productName = TextEditingController();
  TextEditingController looseQuantity = TextEditingController();
  TextEditingController looseSellingPrice = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController animalType = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController purchasePrice = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController barcode = TextEditingController();
  TextEditingController loooseProductName = TextEditingController();
  TextEditingController exprieDate = TextEditingController();
  TextEditingController purchaseDate = TextEditingController();
  RxList<CategoryModel> categoryModel = <CategoryModel>[].obs;

  RxBool isFlavorAndWeightNotRequired = true.obs;
  RxBool isLooseProductSave = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool readOnly = true.obs;
  RxBool dropDownReadOnly = false.obs;
  RxString barcodeValue = ''.obs;
  RxString dayDate = ''.obs;
  bool isLoose = false;

  RxBool isTransferLoading = false.obs;
  var data = Get.arguments;

  @override
  void onInit() {
    dayDate.value = setFormateDate();
    setData();
    getCategoryData();
    super.onInit();
  }

  // ==========================================
  // 🔥 STOCK TRANSFER (SUPABASE + SYNC)
  // ==========================================
  Future<void> requestStockTransfer({
    required ProductModel product,
    required int qty,
  }) async {
    if (userId == null) return;
    if (qty <= 0) {
      showMessage(message: "Invalid quantity");
      return;
    }

    isTransferLoading.value = true;
    try {
      await SupabaseConfig.from('stock_movements').insert({
        'product_id': product.id,
        'user_id': userId,
        'quantity': qty,
        'form_location': 'godown',
        'to_location': 'shop',
        'movement_type': 'transfer',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      showMessage(message: "📤 Stock transfer request sent to Shop");
    } catch (e) {
      showMessage(message: "❌ ${e.toString()}");
    } finally {
      isTransferLoading.value = false;
    }
  }

  void getCategoryData() async {
    await fetchCategories();
    await fetchAnimalCategories();
  }

  CategoryModel? getSelectedCategory({
    required String categorysId,
    String categoryType = '',
  }) {
    try {
      if (categoryType == 'animal') {
        return animalTypeList.firstWhere(
          (e) => e.name == categorysId || e.id == categorysId,
          orElse: () => CategoryModel(),
        );
      } else {
        return categoryList.firstWhere(
          (e) => e.name == categorysId || e.id == categorysId,
          orElse: () => CategoryModel(),
        );
      }
    } catch (e) {
      return null;
    }
  }

  void setData() {
    var productData = data['product'];

    if (productData is ProductModel) {
      ProductModel p = productData;
      category.text = p.category ?? '';
      animalType.text = p.animalType ?? '';
      isFlavorAndWeightNotRequired.value =
          p.isFlavorAndWeightNotRequired ?? false;
      productName.text = p.name ?? '';
      barcode.text = p.barcode ?? '';
      quantity.text = p.quantity.toString();
      sellingPrice.text = p.sellingPrice.toString();
      purchasePrice.text = p.purchasePrice.toString();
      flavor.text = p.flavor ?? '';
      weight.text = p.weight.toString();
      isLoose = p.isLoosed ?? false;
      location.text = p.location ?? '';
      discount.text = p.discount.toString();
      purchaseDate.text = p.purchaseDate ?? '';
      exprieDate.text = p.expireDate ?? '';
    } else if (productData is LooseInvetoryModel) {
      LooseInvetoryModel l = productData;
      category.text = l.category ?? '';
      animalType.text = l.animalType ?? '';
      isFlavorAndWeightNotRequired.value =
          l.isFlavorAndWeightNotRequired ?? false;
      productName.text = l.name ?? '';
      barcode.text = l.barcode ?? '';
      quantity.text = l.quantity.toString();
      sellingPrice.text = l.sellingPrice.toString();
      purchasePrice.text = l.purchasePrice.toString();
      flavor.text = l.flavor ?? '';
      weight.text = l.weight ?? '';
      isLoose = true;
      location.text = l.location ?? '';
      discount.text = l.discount.toString();
      purchaseDate.text = l.purchaseDate ?? '';
      exprieDate.text = l.expireDate ?? '';
    } else {
      Map<String, dynamic> p = productData as Map<String, dynamic>;
      category.text = p['category']?.toString() ?? '';
      animalType.text = p['animalType']?.toString() ?? '';
      isFlavorAndWeightNotRequired.value =
          p['isFlavorAndWeightNotRequired'] ?? false;
      productName.text = p['name']?.toString() ?? '';
      barcode.text = p['barcode']?.toString() ?? '';
      quantity.text = p['quantity']?.toString() ?? '0';
      sellingPrice.text = p['sellingPrice']?.toString() ?? '0';
      purchasePrice.text = p['purchasePrice']?.toString() ?? '0';
      flavor.text = p['flavor']?.toString() ?? '';
      weight.text = p['weight']?.toString() ?? '';
      isLoose = p['isLoosed'] ?? p['isLooseCategory'] ?? false;
      location.text = p['location']?.toString() ?? '';
      discount.text = p['discount']?.toString() ?? '0';
      purchaseDate.text = p['purchaseDate']?.toString() ?? '';
      exprieDate.text = p['expireDate']?.toString() ?? '';
    }
  }

  // ==========================================
  // 🔥 UPDATE: Supabase RPC -> Hive Local Update
  // ==========================================
  void updateProductQuantity({
    required String barcode,
    required bool isLoosed,
    required String locationType,
  }) async {
    if (userId == null) return;
    isSaveLoading.value = true;

    try {
      var catId =
          categoryList.firstWhereOrNull((e) => e.name == category.text)?.id;
      var aniId =
          animalTypeList.firstWhereOrNull((e) => e.name == animalType.text)?.id;

      String? pid;
      var productData = data['product'];
      if (productData is ProductModel) {
        pid = productData.id;
      } else if (productData is LooseInvetoryModel) {
        pid = productData.productId;
      } else {
        pid =
            productData['id']?.toString() ??
            productData['productId']?.toString();
      }

      if (pid == null) throw "Product ID not found";

      // 1. Transactional Update (Cloud)
      await SupabaseConfig.client.rpc(
        'update_product_and_stock_transaction',
        params: {
          'p_pid': pid,
          'p_user_id': userId,
          'p_name': productName.text.trim(),
          'p_cat_id': catId,
          'p_ani_id': aniId,
          'p_flavor': flavor.text,
          'p_weight': weight.text,
          'p_is_loose_cat': isLoosed,
          'p_is_flavor_weight_req': isFlavorAndWeightNotRequired.value,
          'p_is_loosed_entry': isLoosed,
          'p_qty': double.tryParse(quantity.text) ?? 0.0,
          'p_s_price': double.tryParse(sellingPrice.text) ?? 0.0,
          'p_p_price': double.tryParse(purchasePrice.text) ?? 0.0,
          'p_p_date': formatDateForDB(purchaseDate.text),
          'p_e_date': formatDateForDB(exprieDate.text),
          'p_location': location.text.toLowerCase().trim(),
        },
      );

      // 2. Local Sync: Hive mein purana data update karna
      // Hum direct list fetch karke Hive overwrite kar rahe hain taaki data consistency bani rahe
      await refreshAllLocalData(isLoosed: isLoosed);
      Get.back(result: true);
      showMessage(message: '✅ Product & Stock Updated Safely.');
    } catch (e) {
      print("🚨 Update Error: $e");
      showMessage(message: "❌ Error: Update failed. Check Internet.");
    } finally {
      isSaveLoading.value = false;
    }
  }

  // 🔥 Helper function for full Hive refresh
  Future<void> refreshAllLocalData({required bool isLoosed}) async {
    if (userId == null) return;
    if (isLoosed == true) {
      try {
        final response = await SupabaseConfig.from('products')
            .select('*, product_stock!inner(*)')
            .eq('user_id', userId!)
            .eq('product_stock.is_active', true);

        final freshList =
            (response as List).map((e) => ProductModel.fromJson(e)).toList();
        await LocalService.saveProducts(freshList);
      } catch (e) {
        print("🚨 Background Sync failed: $e");
      }
    } else {
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
            .eq('user_id', userId!)
            .order('created_at', ascending: false);

        final List data = response as List;
        final List<LooseInvetoryModel> loosedfreshList =
            data.map((e) => LooseInvetoryModel.fromJson(e)).toList();

        // 3. UI Update aur Hive Update
        looseInventoryLis.value = loosedfreshList;
        await LocalService.saveLooseProducts(loosedfreshList);
      } catch (e) {}
    }
  }

  // ==========================================
  // 🔥 FETCH DATA (HIVE FIRST + FALLBACK)
  // ==========================================
  Future<void> fetchCategories() async {
    // 1. Pehle Hive se load karo
    final cached = LocalService.getCachedCategories();
    if (cached.isNotEmpty) {
      categoryList.value = cached;
    }

    // 2. Fallback to Supabase
    if (userId == null) return;
    try {
      final List response = await SupabaseConfig.from(
        'categories',
      ).select().eq('user_id', userId!);
      final freshData = response.map((e) => CategoryModel.fromJson(e)).toList();

      categoryList.value = freshData;
      await LocalService.saveCategories(freshData); // Hive Update
    } catch (e) {
      print("🚨 Category fetch error: $e");
    }
  }

  Future<void> fetchAnimalCategories() async {
    // 1. Hive Load
    final cached = LocalService.getCachedAnimalCategories();
    if (cached.isNotEmpty) {
      animalTypeList.value = cached;
    }

    // 2. Supabase Sync
    if (userId == null) return;
    try {
      final List response = await SupabaseConfig.from(
        'animal_categories',
      ).select().eq('user_id', userId!);
      final freshData = response.map((e) => CategoryModel.fromJson(e)).toList();

      animalTypeList.value = freshData;
      await LocalService.saveAnimalCategories(freshData); // Hive Update
    } catch (e) {
      print("🚨 Animal category error: $e");
    }
  }
}
