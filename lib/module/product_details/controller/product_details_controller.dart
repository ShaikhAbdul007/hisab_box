import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import '../../../helper/helper.dart';
import '../../../helper/set_format_date.dart';
import '../../category/model/category_model.dart';
import '../../inventory/model/product_model.dart';

class ProductDetailsController extends GetxController with CacheManager {
  // Supabase Config use kar rahe hain
  final userId = SupabaseConfig.auth.currentUser?.id;

  final inventoryScanKey = GlobalKey<FormState>();
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
  RxList<ProductModel> looseCatogorieList = <ProductModel>[].obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<ProductModel> looseInventoryLis = <ProductModel>[].obs;
  RxList<ProductModel> fullLooseSellingList = <ProductModel>[].obs;

  // Controllers (Wahi rakhe hain jo tune diye)
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
  // 🔥 STOCK TRANSFER (SUPABASE INSERT)
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
    required String categorysId, // Isme ab ID ya Name aa sakta hai
    String categoryType = '',
  }) {
    try {
      if (categoryType == 'animal') {
        // Animal types list mein se dhoondo
        return animalTypeList.firstWhere(
          (e) => e.name == categorysId || e.id == categorysId,
          orElse: () => CategoryModel(),
        );
      } else {
        // Main categories list mein se dhoondo
        return categoryList.firstWhere(
          (e) => e.name == categorysId || e.id == categorysId,
          orElse: () => CategoryModel(),
        );
      }
    } catch (e) {
      // Error finding category: $e
      return null;
    }
  }

  void setData() {
    // Handle both ProductModel and LooseInventoryModel
    var productData = data['product'];

    if (productData is ProductModel) {
      // ProductModel case
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
      // LooseInventoryModel case
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
      isLoose = true; // Always true for loose products
      location.text = l.location ?? '';
      discount.text = l.discount.toString();
      purchaseDate.text = l.purchaseDate ?? '';
      exprieDate.text = l.expireDate ?? '';
    } else {
      // Fallback for dynamic/Map case
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
  // 🔥 UPDATE PRODUCT (RELATIONAL UPDATE)
  // ==========================================
  void updateProductQuantity({
    required String barcode,
    required bool isLoosed,
    required String locationType,
  }) async {
    if (userId == null) return;
    isSaveLoading.value = true;

    try {
      // 1. Get IDs for Category and Animal Type from the observable lists
      var categoryItem = categoryList.firstWhereOrNull(
        (e) => e.name == category.text,
      );
      var animalItem = animalTypeList.firstWhereOrNull(
        (e) => e.name == animalType.text,
      );

      String? catId = categoryItem?.id;
      String? aniId = animalItem?.id;

      // 2. Get product ID from different sources
      String? pid;
      var productData = data['product'];

      if (productData is ProductModel) {
        pid = productData.id;
      } else if (productData is LooseInvetoryModel) {
        pid = productData.productId; // LooseInventoryModel uses productId
      } else {
        pid =
            productData['id']?.toString() ??
            productData['productId']?.toString();
      }

      if (pid == null) {
        showMessage(message: "❌ Product ID not found");
        return;
      }

      // 3. Update Main Products Table (Name, Category, etc.)
      await SupabaseConfig.from('products')
          .update({
            'name': productName.text,
            'category': catId,
            'animal_type': aniId,
            'flavour': flavor.text,
            'weight': weight.text,
            'is_flavor_and_weight_not_required':
                isFlavorAndWeightNotRequired.value,
            'is_loose_category': isLoosed,
          })
          .eq('id', pid);

      // 4. Update appropriate stock table based on product type
      if (isLoosed) {
        // Update loose_stocks table
        await SupabaseConfig.from('loose_stocks')
            .update({
              'quantity': int.tryParse(quantity.text) ?? 0,
              'selling_price': double.tryParse(sellingPrice.text) ?? 0.0,
            })
            .eq('product_id', pid)
            .eq('user_id', userId!);
      } else {
        // Update product_stock table
        await SupabaseConfig.from('product_stock')
            .update({
              'quantity': num.tryParse(quantity.text) ?? 0,
              'selling_price': double.tryParse(sellingPrice.text) ?? 0.0,
              'location': location.text.toLowerCase(),
              'stock_type': 'packet',
            })
            .eq('product_id', pid)
            .eq('user_id', userId!)
            .eq('location', location.text.toLowerCase());
      }

      // 5. Update stock_batches if needed (for purchase/expiry dates)
      if (purchaseDate.text.isNotEmpty || exprieDate.text.isNotEmpty) {
        await SupabaseConfig.from('stock_batches')
            .update({
              'purchase_price': double.tryParse(purchasePrice.text) ?? 0.0,
              'purchase_date':
                  purchaseDate.text.isNotEmpty ? purchaseDate.text : null,
              'expiry_date':
                  exprieDate.text.isNotEmpty ? exprieDate.text : null,
            })
            .eq('product_id', pid)
            .eq('user_id', userId!);
      }

      Get.back(result: true);
      showMessage(message: '✅ Product Info updated.');
    } catch (e) {
      showMessage(message: "❌ Error: $e");
    } finally {
      isSaveLoading.value = false;
    }
  }

  // ==========================================
  // 🔥 FETCH DATA (SUPABASE)
  // ==========================================
  Future<void> fetchCategories() async {
    var categorList = await retrieveCategoryModel();
    if (categorList.isNotEmpty) {
      categoryList.value = categorList;
    } else {
      if (userId == null) return;
      try {
        final List response = await SupabaseConfig.from(
          'categories',
        ).select().eq('user_id', userId!);
        categoryList.value =
            response.map((e) => CategoryModel.fromJson(e)).toList();
        saveCategoryModel(categoryList);
      } catch (e) {
        // Error loading categories
      }
    }
  }

  Future<void> fetchAnimalCategories() async {
    var animalCategorList = await retrieveAnimalCategoryModel();
    if (animalCategorList.isNotEmpty) {
      animalTypeList.value = animalCategorList;
    } else {
      if (userId == null) return;
      try {
        final List response = await SupabaseConfig.from(
          'animal_categories',
        ).select().eq('user_id', userId!);
        animalTypeList.value =
            response.map((e) => CategoryModel.fromJson(e)).toList();
        saveAnimalCategoryModel(animalTypeList);
      } catch (e) {
        // Error loading animal categories
      }
    }
  }
}
