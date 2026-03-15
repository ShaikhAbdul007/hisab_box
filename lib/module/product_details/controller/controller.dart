import 'package:inventory/helper/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/gobal_module/gobal_controller.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import '../../../helper/helper.dart';
import '../../category/model/category_model.dart';
import '../../inventory/model/product_model.dart';

class ProductController extends GetxController with CacheManager, LocalService {
  final globalStore = Get.find<GlobalStore>();
  final inventoryScanKey = GlobalKey<FormState>();

  // Observables (Exactly as you had them)
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  var productList = <ProductModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
  RxList<ProductModel> looseCatogorieList = <ProductModel>[].obs;
  RxList<LooseInvetoryModel> looseInventoryLis = <LooseInvetoryModel>[].obs;
  RxList<ProductModel> fullLooseSellingList = <ProductModel>[].obs;

  // Controllers
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
    // Categories aur Animals ko fetch karna padega kyunki ye GlobalStore mein nahi hain
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
    barcode.text = data['barcode'] ?? '';
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

  // 🔥 FETCH CATEGORIES (From Hive then Supabase)
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

  // 🔥 SAVE NEW PRODUCT
  Future<void> saveNewProduct({required String barcode}) async {
    isSaveLoading.value = true;
    try {
      final userId = resolveUserId(isSaveLoading.value);
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

  // 🔥 SAVE LOOSE PRODUCT
  Future<void> saveNewLooseProduct({required String barcode}) async {
    isLooseProductSave.value = true;
    try {
      final userId = resolveUserId(isLooseProductSave.value);
      if (userId == null) return;
      await SupabaseConfig.client.rpc(
        'convert_packet_to_loose',
        params: {
          'p_user_id': userId,
          'p_barcode': barcode,
          //'p_qty': double.tryParse(looseQuantity.text) ?? 0,
          'p_loose_qty': double.tryParse(looseQuantity.text) ?? 0,
          'p_selling_price': double.tryParse(sellingPrice.text) ?? 0,
          'p_reason': 'convert',
        },
      );
      await globalStore.loadInitialData();

      showMessage(message: "✅ Converted & Synced!");
      clear();
      Get.back(result: true);
    } catch (e) {
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isLooseProductSave.value = false;
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

  @override
  void dispose() {
    productName.dispose();
    looseQuantity.dispose();
    looseSellingPrice.dispose();
    category.dispose();
    animalType.dispose();
    sellingPrice.dispose();
    location.dispose();
    discount.dispose();
    purchasePrice.dispose();
    level.dispose();
    rack.dispose();
    flavor.dispose();
    weight.dispose();
    quantity.dispose();
    barcode.dispose();
    purchaseDate.dispose();
    exprieDate.dispose();
    loooseProductName.dispose();
    super.dispose();
  }
}
