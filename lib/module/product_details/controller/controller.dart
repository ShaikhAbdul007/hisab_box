import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/category/repo/animal_category_repo.dart';
import 'package:inventory/module/category/repo/category_repo.dart';
import 'package:inventory/module/color_category/repo/color_category_repo.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/module/product_details/repo/product_repo.dart';
import '../../../helper/helper.dart';
import '../../category/model/category_model.dart';

class ProductController extends GetxController with CacheManager {
  final inventoryScanKey = GlobalKey<FormState>();
  ProductRepo productRepo = ProductRepo();
  CategoryRepo categoryRepo = CategoryRepo();
  AnimalCategoryRepo animalCategoryRepo = AnimalCategoryRepo();
  ColorCategoryRepo colorCategoryRepo = ColorCategoryRepo();

  RxList<CategoryModelListData> categoryList = <CategoryModelListData>[].obs;
  RxList<CategoryModelListData> animalTypeList = <CategoryModelListData>[].obs;
  RxList<CategoryModelListData> colorList = <CategoryModelListData>[].obs;
  RxList<InventoryItem> looseCatogorieList = <InventoryItem>[].obs;
  RxList<LooseInvetoryModel> looseInventoryLis = <LooseInvetoryModel>[].obs;

  // Selected IDs
  RxnString selectedCategoryId = RxnString(null);
  RxnString selectedAnimalTypeId = RxnString(null);
  RxnString selectedColorId = RxnString(null);

  // Controllers
  TextEditingController productName = TextEditingController();
  TextEditingController looseQuantity = TextEditingController();
  TextEditingController looseSellingPrice = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController animalType = TextEditingController();
  TextEditingController color = TextEditingController();
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
  RxString scannedBarcodeValue = ''.obs;
  RxBool loosedProduct = false.obs;
  RxBool categoryListLoading = false.obs;
  RxBool animalCategoryListLoading = false.obs;
  RxBool colorListLoading = false.obs;
  RxString dayDate = ''.obs;
  RxString shopType = ''.obs;
  RxString brandType = ''.obs;
  RxList<String> locationOptions = <String>['Shop'].obs;
  bool isLoose = false;

  ShopType get shopTypeEnum => ShopType.fromString(shopType.value);
  var data = Get.arguments;

  @override
  void onInit() async {
    dayDate.value = setFormateDate();
    purchaseDate.text = setFormateDate(); // default today
    setLoosedProduct();
    await retrieveGodownValue();
    setBarcode();
    getCategoryData();
    super.onInit();
  }

  Future<void> retrieveGodownValue() async {
    final isGodownEnabled = await retrieveGodown();
    locationOptions.value =
        isGodownEnabled ? <String>['Shop', 'Godown'] : <String>['Shop'];
    if (!locationOptions.contains(location.text)) {
      location.text = locationOptions.first;
    }
  }

  void setLoosedProduct() {
    var user = retrieveUserDetail();
    shopType.value = user.data?.shopType ?? '';
    loosedProduct.value = data['flag'];
    if (loosedProduct.value) {
      loooseProductName.text = data['productName'];
    }
  }

  void setBarcode() {
    barcode.text = data['barcode'] ?? '';
    scannedBarcodeValue.value = barcode.text;
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
    if (shopTypeEnum == ShopType.clothingShop) {
      await fetchColorCategories();
    }
  }

  Future<void> fetchCategories() async {
    categoryListLoading.value = true;
    try {
      final cached = await retrieveCategory();
      if (cached.isNotEmpty) categoryList.value = cached;
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
      final cached = await retrieveAnimalCategory();
      if (cached.isNotEmpty) animalTypeList.value = cached;
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
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isLooseProductSave.value = false;
    }
  }

  Future<void> saveNewGrProduct({required dynamic body}) async {
    isLooseProductSave.value = true;
    try {
      var response = await productRepo.addGrProduct(body: body);
      if (response.success == success) {
        clear();
        Get.back(result: true);
        showMessage(
          message: response.data?.message ?? response.msg ?? somethingWentMessage,
        );
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }
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

  @override
  void dispose() {
    productName.dispose();
    looseQuantity.dispose();
    looseSellingPrice.dispose();
    category.dispose();
    animalType.dispose();
    color.dispose();
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
