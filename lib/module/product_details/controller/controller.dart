import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/module/product_details/repo/product_repo.dart';
import '../../../helper/helper.dart';
import '../../category/model/category_model.dart';
import '../../inventory/model/product_model.dart';

class ProductController extends GetxController with CacheManager, LocalService {
  final inventoryScanKey = GlobalKey<FormState>();
  ProductRepo productRepo = ProductRepo();

  RxList<CategoryModelListData> categoryList = <CategoryModelListData>[].obs;
  RxList<CategoryModelListData> animalTypeList = <CategoryModelListData>[].obs;
  RxList<ProductModel> looseCatogorieList = <ProductModel>[].obs;
  RxList<LooseInvetoryModel> looseInventoryLis = <LooseInvetoryModel>[].obs;

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

  // 🔥 SAVE NEW PRODUCT
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

  // 🔥 SAVE LOOSE PRODUCT
  Future<void> saveNewLooseProduct({required dynamic body}) async {
    isLooseProductSave.value = true;
    try {
      var response = await productRepo.addLoosedProduct(body: body);
      if (response.success == success) {
        clear();
        Get.back(result: true);
        showMessage(message: response.msg ?? somethingWentMessage);
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }

      showSnackBar(error: "✅ Converted & Synced!");
      clear();
      Get.back(result: true);
    } catch (e) {
      showSnackBar(error: e.toString());
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
