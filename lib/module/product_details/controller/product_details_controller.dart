import 'package:inventory/helper/logger.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/capitalization_strings.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 Hive Service
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import '../../../helper/helper.dart';
import '../../../helper/set_format_date.dart';
import '../../category/model/category_model.dart';
import '../../inventory/model/product_model.dart';
import 'package:inventory/gobal_controller.dart'; // 🔥 GlobalStore Connection

class ProductDetailsController extends GetxController with LocalService {
  final userId = SupabaseConfig.auth.currentUser?.id;
  final globalStore = Get.find<GlobalStore>(); // 🔥 GlobalStore Reference

  final inventoryScanKey = GlobalKey<FormState>();
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
  RxList<ProductModel> looseCatogorieList = <ProductModel>[].obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<LooseInvetoryModel> looseInventoryLis = <LooseInvetoryModel>[].obs;
  RxList<ProductModel> fullLooseSellingList = <ProductModel>[].obs;
  TextEditingController transferQuantityToShop = TextEditingController();
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
  TextEditingController barcodeQytController = TextEditingController();
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
    required double requestedQty,
  }) async {
    if (userId == null) return;

    // 1. Validation: Quantity check
    if (requestedQty <= 0) {
      showMessage(message: "Invalid quantity");
      return;
    }

    // 2. Physical Stock Check (Godown Check)
    if ((product.quantity ?? 0) < requestedQty) {
      showMessage(
        message: "Insufficient stock in Godown! Available: ${product.quantity}",
      );
      return;
    }

    isTransferLoading.value = true;
    try {
      String refId = "TRF-${DateTime.now().millisecondsSinceEpoch}";

      // 🔥 STEP 1: Stock Movement Insert (Tracking ke liye)
      await SupabaseConfig.from('stock_movements').insert({
        'user_id': userId,
        'product_id': product.id,
        'quantity': requestedQty,
        'form_location': 'godown',
        'to_location': 'shop',
        'movement_type': 'transfer',
        'status': 'pending',
        'reference_id': refId,
        'stock_type': product.stockType ?? 'packet',
        'price': product.sellingPrice ?? 0.0,
        'reason': 'Stock transfer from Godown',
        'created_at': DateTime.now().toIso8601String(),
      });

      // 🔥 STEP 2: Godown Stock Minus (Hold Logic)
      // Isse 10 vs 15 wali problem solve ho gayi
      await SupabaseConfig.from('product_stock')
          .update({
            'quantity': (product.quantity ?? 0) - requestedQty,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('product_id', product.id!)
          .eq('location', 'godown');

      // 🔥 STEP 3: Notification Table mein Entry
      await SupabaseConfig.from('notifications').insert({
        'user_id':
            userId, // Shop manager ki ID (agar multi-user hai toh manager ki ID pass karein)
        'title': "📦 New Stock Incoming!",
        'body':
            "${product.name} ke $requestedQty units Godown se bheje gaye hain. (ID: $refId)",
        'is_read': false,
        'payload': {
          'type': 'transfer',
          'ref_id': refId,
          'product_id': product.id,
        },
        'created_at': DateTime.now().toIso8601String(),
      });

      showMessage(
        message: "📤 Transfer Request Sent & Notification Delivered!",
      );
      Get.back();
    } catch (e) {
      print("🚨 Transfer Error: $e");
      showMessage(message: "Failed to process transfer request");
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
      barcodeQytController.text = p.quantity.toString();

      sellingPrice.text = p.sellingPrice.toString();
      purchasePrice.text = p.purchasePrice.toString();
      flavor.text = p.flavor ?? '';
      weight.text = p.weight.toString();
      isLoose = p.isLooseCategory ?? false;
      location.text = p.location?.toCapitalized() ?? '';
      discount.text = p.discount.toString();
      purchaseDate.text = formatDateForUi(p.purchaseDate, emptyFallback: '');
      exprieDate.text = formatDateForUi(p.expireDate, emptyFallback: '');
    } else if (productData is LooseInvetoryModel) {
      LooseInvetoryModel l = productData;
      category.text = l.category ?? '';
      animalType.text = l.animalType ?? '';
      isFlavorAndWeightNotRequired.value =
          l.isFlavorAndWeightNotRequired ?? false;
      productName.text = l.name ?? '';
      barcode.text = l.barcode ?? '';
      quantity.text = l.quantity.toString();
      barcodeQytController.text = l.quantity.toString();
      sellingPrice.text = l.sellingPrice.toString();
      purchasePrice.text = l.purchasePrice.toString();
      flavor.text = l.flavor ?? '';
      weight.text = l.weight ?? '';
      isLoose = true;
      location.text = l.location?.toCapitalized() ?? '';
      discount.text = l.discount.toString();
      purchaseDate.text = formatDateForUi(l.purchaseDate, emptyFallback: '');
      exprieDate.text = formatDateForUi(l.expireDate, emptyFallback: '');
    } else {
      Map<String, dynamic> p = productData as Map<String, dynamic>;
      category.text = p['category']?.toString() ?? '';
      animalType.text =
          p['animalType']?.toString() ?? p['animal_type']?.toString() ?? '';
      isFlavorAndWeightNotRequired.value =
          p['isFlavorAndWeightNotRequired'] ??
          p['is_flavor_and_weight_not_required'] ??
          false;
      productName.text = p['name']?.toString() ?? '';
      barcode.text = p['barcode']?.toString() ?? '';
      quantity.text = p['quantity']?.toString() ?? '0';
      barcodeQytController.text = p['quantity']?.toString() ?? '0';
      sellingPrice.text = p['sellingPrice']?.toString() ?? '0';
      purchasePrice.text = p['purchasePrice']?.toString() ?? '0';
      flavor.text = p['flavor']?.toString() ?? p['flavour']?.toString() ?? '';
      weight.text = p['weight']?.toString() ?? '';
      isLoose = p['isLoosed'] ?? p['isLooseCategory'] ?? false;
      location.text = p['location']?.toString() ?? '';
      discount.text = p['discount']?.toString() ?? '0';
      purchaseDate.text = formatDateForUi(
        p['purchaseDate']?.toString() ?? p['purchase_date']?.toString(),
        emptyFallback: '',
      );
      exprieDate.text = formatDateForUi(
        p['expireDate']?.toString() ?? p['expiry_date']?.toString(),
        emptyFallback: '',
      );
    }
  }

  // ==========================================
  // 🔥 UPDATE: Supabase RPC -> Global Sync -> Hive Update
  // ==========================================
  void updateProductQuantity({
    required String barcode,
    required bool isLoosed,
    required String locationType,
  }) async {
    if (userId == null) return;
    isSaveLoading.value = true;

    try {
      final selectedCategory = category.text.trim();
      final selectedAnimal = animalType.text.trim();

      final catId =
          categoryList
              .firstWhereOrNull(
                (e) => e.id == selectedCategory || e.name == selectedCategory,
              )
              ?.id ??
          (selectedCategory.isEmpty ? null : selectedCategory);

      final aniId =
          animalTypeList
              .firstWhereOrNull(
                (e) => e.id == selectedAnimal || e.name == selectedAnimal,
              )
              ?.id ??
          (selectedAnimal.isEmpty ? null : selectedAnimal);

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
      final pDate = formatDateForRpc(purchaseDate.text);
      final eDate = formatDateForRpc(exprieDate.text);
      // 1. Transactional Update (Cloud)
      await SupabaseConfig.client.rpc(
        'update_product_and_stock_v2',
        params: {
          'p_pid': pid,
          'p_user_id': userId,
          'p_name': productName.text.trim(),
          'p_cat_id': catId,
          'p_ani_id': aniId,
          'p_flavor': flavor.text,
          'p_weight': weight.text,
          'p_is_loose_cat': isLoose,
          'p_is_flavor_weight_req': isFlavorAndWeightNotRequired.value,
          'p_is_loosed_entry': isLoosed,
          'p_qty': double.tryParse(quantity.text) ?? 0.0,
          'p_s_price': double.tryParse(sellingPrice.text) ?? 0.0,
          'p_p_price': double.tryParse(purchasePrice.text) ?? 0.0,
          'p_p_date': pDate,
          'p_e_date': eDate,
          'p_location': location.text.toLowerCase().trim(),
        },
      );

      // 2. 🔥 GLOBAL SYNC: GlobalStore ko bolo fresh data laaye
      // Isse RAM wala data update hoga aur poori app refresh ho jayegi
      await globalStore.loadInitialData();
      // 3. Local Sync: Hive mein data update karna
      await refreshAllLocalData(isLoosed: isLoosed);
      Get.back(result: true);
      showMessage(message: '✅ Product & Stock Updated Safely.');
    } catch (e) {
      AppLogger.info(("🚨 Update Error: $e").toString());
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isSaveLoading.value = false;
    }
  }

  // 🔥 Helper function for full Hive refresh
  Future<void> refreshAllLocalData({required bool isLoosed}) async {
    if (userId == null) return;
    if (isLoosed == false) {
      // Based on your logic if NOT loose
      try {
        final response = await SupabaseConfig.from('products')
            .select('*, product_stock!inner(*)')
            .eq('user_id', userId!)
            .eq('product_stock.is_active', true);

        final freshList =
            (response as List).map((e) => ProductModel.fromJson(e)).toList();
        await LocalService.saveProducts(freshList);
      } catch (e) {
        AppLogger.info(("🚨 Background Sync failed: $e").toString());
        showMessage(message: SupabaseErrorHandler.getMessage(e));
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

        final List dataResponse = response as List;
        final List<LooseInvetoryModel> loosedfreshList =
            dataResponse.map((e) => LooseInvetoryModel.fromJson(e)).toList();

        looseInventoryLis.value = loosedfreshList;
        await LocalService.saveLooseProducts(loosedfreshList);
      } catch (e) {
        AppLogger.info(("🚨 Loose Sync failed: $e").toString());
        showMessage(message: SupabaseErrorHandler.getMessage(e));
      }
    }
  }

  Future<void> fetchCategories() async {
    final cached = LocalService.getCachedCategories();
    if (cached.isNotEmpty) {
      categoryList.value = cached;
    }
    if (userId == null) return;
    try {
      final List response = await SupabaseConfig.from(
        'categories',
      ).select().eq('user_id', userId!);
      final freshData = response.map((e) => CategoryModel.fromJson(e)).toList();
      categoryList.value = freshData;
      await LocalService.saveCategories(freshData);
    } catch (e) {
      AppLogger.info(("🚨 Category fetch error: $e").toString());
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    }
  }

  Future<void> fetchAnimalCategories() async {
    final cached = LocalService.getCachedAnimalCategories();
    if (cached.isNotEmpty) {
      animalTypeList.value = cached;
    }
    if (userId == null) return;
    try {
      final List response = await SupabaseConfig.from(
        'animal_categories',
      ).select().eq('user_id', userId!);
      final freshData = response.map((e) => CategoryModel.fromJson(e)).toList();
      animalTypeList.value = freshData;
      await LocalService.saveAnimalCategories(freshData);
    } catch (e) {
      AppLogger.info(("🚨 Animal category error: $e").toString());
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    }
  }
}
