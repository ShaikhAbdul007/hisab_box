import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/gobal_module/gobal_controller.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/module/product_details/repo/product_repo.dart';
import '../../../helper/helper.dart';
import '../../../helper/set_format_date.dart';
import '../../category/model/category_model.dart';
import 'package:get/get.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Mixin
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/module/inventory/model/product_model.dart';

class GenerateBarcodeController extends GetxController with CacheManager {
  ProductRepo productRepo = ProductRepo();
  RxBool categoryListLoading = false.obs;
  final inventoryScanKey = GlobalKey<FormState>();
  RxBool animalCategoryListLoading = false.obs;
  RxList<CategoryModelListData> categoryList = <CategoryModelListData>[].obs;
  RxList<CategoryModelListData> animalTypeList = <CategoryModelListData>[].obs;
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
    super.onInit();
  }

  @override
  void onReady() {
    getCategoryDataAndAnimalData();
    super.onReady();
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

    try {
      final cached = await retrieveCategory();
      if (cached.isNotEmpty) {
        categoryList.value = cached;
      }
    } catch (e) {
      AppLogger.info(("🚨 Category Error: $e").toString());
      showSnackBar(error: e.toString());
    } finally {
      categoryListLoading.value = false;
    }
  }

  // 🔥 FETCH ANIMAL CATEGORIES
  Future<void> fetchAnimalCategories() async {
    animalCategoryListLoading.value = true;

    try {
      var cached = await retrieveAnimalCategory();
      if (cached.isNotEmpty) {
        animalTypeList.value = cached;
      }
    } catch (e) {
      AppLogger.info(("🚨 Animal Error: $e").toString());
      showSnackBar(error: e.toString());
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

  Future<void> saveNewProduct({required dynamic body}) async {
    isSaveLoading.value = true;
    try {
      var response = await productRepo.addProduct(body: body);
      if (response.success == success) {
        clear();
        Get.back(result: true);
        showMessage(message: response.msg ?? somethingWentMessage);
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }
    } catch (e) {
      AppLogger.info(("Database Error: $e").toString());
      showSnackBar(error: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  // --- 4. Delete Product (Supabase Delete + Hive Update) ---
  Future<void> deleteProduct(String productId) async {
    try {
      // 1. Supabase se delete karo
      // await SupabaseConfig.from('products').delete().eq('id', productId);

      // 2. Hive se delete karo
      // List<InventoryItem> currentCachedProducts =
      //     LocalService.getCachedProducts();
      // currentCachedProducts.removeWhere((p) => p.id == productId);
      // await LocalService.saveProducts(currentCachedProducts);

      showSnackBar(error: "Product deleted successfully");
    } catch (e) {
      AppLogger.info(("🚨 Delete Error: $e").toString());
      showSnackBar(error: e.toString());
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
