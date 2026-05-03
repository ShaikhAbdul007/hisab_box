import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/category/repo/animal_category_repo.dart';
import 'package:inventory/module/category/repo/category_repo.dart';
import 'package:inventory/module/color_category/repo/color_category_repo.dart';
import 'package:inventory/module/product_details/repo/product_repo.dart';
import '../../../helper/helper.dart';
import '../../../helper/set_format_date.dart';
import 'package:get/get.dart';

class GenerateBarcodeController extends GetxController with CacheManager {
  ProductRepo productRepo = ProductRepo();
  CategoryRepo categoryRepo = CategoryRepo();
  AnimalCategoryRepo animalCategoryRepo = AnimalCategoryRepo();
  ColorCategoryRepo colorCategoryRepo = ColorCategoryRepo();

  RxBool categoryListLoading = false.obs;
  RxBool animalCategoryListLoading = false.obs;
  RxBool colorListLoading = false.obs;

  final inventoryScanKey = GlobalKey<FormState>();
  RxList<CategoryModelListData> categoryList = <CategoryModelListData>[].obs;
  RxList<CategoryModelListData> animalTypeList = <CategoryModelListData>[].obs;
  RxList<CategoryModelListData> colorList = <CategoryModelListData>[].obs;

  TextEditingController level = TextEditingController();
  TextEditingController rack = TextEditingController();
  TextEditingController productName = TextEditingController();
  TextEditingController looseQuantity = TextEditingController();
  TextEditingController looseSellingPrice = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController animalType = TextEditingController();
  TextEditingController color = TextEditingController();
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
  RxString shopType = ''.obs;
  RxString brandType = ''.obs;

  // Selected IDs for dropdowns
  RxnString selectedCategoryId = RxnString(null);
  RxnString selectedAnimalTypeId = RxnString(null);
  RxnString selectedColorId = RxnString(null);

  ShopType get shopTypeEnum => ShopType.fromString(shopType.value);

  @override
  void onInit() {
    setBarcode();
    dayDate.value = setFormateDate();
    purchaseDate.text = setFormateDate(); // default today
    final user = retrieveUserDetail();
    shopType.value = user.data?.shopType ?? '';
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
    if (shopTypeEnum == ShopType.clothingShop) {
      await fetchColorCategories();
    }
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
      // Cache first
      final cached = await retrieveCategory();
      if (cached.isNotEmpty) categoryList.value = cached;
      // Always fetch fresh from API
      final response = await categoryRepo.getCategory();
      if (response.success == success) {
        categoryList.value = response.categorymodeldata?.data ?? [];
        saveCategoryList(categoryList);
      }
    } catch (e) {
      AppLogger.info(("🚨 Category Error: $e").toString());
    } finally {
      categoryListLoading.value = false;
    }
  }

  Future<void> fetchAnimalCategories() async {
    animalCategoryListLoading.value = true;
    try {
      // Cache first
      final cached = await retrieveAnimalCategory();
      if (cached.isNotEmpty) animalTypeList.value = cached;
      // Always fetch fresh from API
      final response = await animalCategoryRepo.getAnimalCategory();
      if (response.success == success) {
        animalTypeList.value = response.categorymodeldata?.data ?? [];
        saveAnimalList(animalTypeList);
      }
    } catch (e) {
      AppLogger.info(("🚨 Animal Error: $e").toString());
    } finally {
      animalCategoryListLoading.value = false;
    }
  }

  Future<void> fetchColorCategories() async {
    colorListLoading.value = true;
    try {
      final response = await colorCategoryRepo.getColorCategories();
      if (response.success == success) {
        colorList.value = response.categorymodeldata?.data ?? [];
      }
    } catch (e) {
      AppLogger.info(("🚨 Color Error: $e").toString());
    } finally {
      colorListLoading.value = false;
    }
  }

  String generateBarcodeNo() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timeStr = timestamp.toString();
    String uniqueSuffix = timeStr.substring(timeStr.length - 8);
    int randomExtra = Random().nextInt(90) + 10;
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

  void clear() {
    barcode.clear();
    productName.clear();
    looseQuantity.clear();
    looseSellingPrice.clear();
    category.clear();
    color.clear();
    sellingPrice.clear();
    purchasePrice.clear();
    flavor.clear();
    weight.clear();
    quantity.clear();
    selectedCategoryId.value = null;
    selectedAnimalTypeId.value = null;
    selectedColorId.value = null;
    brandType.value = '';
  }
}
