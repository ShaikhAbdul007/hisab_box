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
import 'package:inventory/module/inventorylist/controller/inventory_list_controller.dart';

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
  RxList<String> locationOptions = <String>['Shop'].obs;

  // Selected IDs for dropdowns
  RxnString selectedCategoryId = RxnString(null);
  RxnString selectedAnimalTypeId = RxnString(null);
  RxnString selectedColorId = RxnString(null);

  // ── Clothing Matrix: multi-select colors + sizes ──────────────────────────
  RxList<CategoryModelListData> selectedColors = <CategoryModelListData>[].obs;
  RxList<CategoryModelListData> selectedSizes = <CategoryModelListData>[].obs;
  RxList<Map<String, dynamic>> variantCombinations =
      <Map<String, dynamic>>[].obs;
  RxBool isSavingVariants = false.obs;

  ShopType get shopTypeEnum => ShopType.fromString(shopType.value);

  @override
  void onInit() {
    setBarcode();
    dayDate.value = setFormateDate();
    purchaseDate.text = setFormateDate(); // default today
    final user = retrieveUserDetail();
    shopType.value = user.data?.shopType ?? '';
    retrieveGodownValue();
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
      if (cached.isNotEmpty) {
        categoryList.value = cached;
      }
      // Always fetch fresh from API
      else {
        final response = await categoryRepo.getCategory();
        if (response.success == success) {
          categoryList.value = response.data ?? [];
          saveCategoryList(categoryList);
        }
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
      if (cached.isNotEmpty) {
        animalTypeList.value = cached;
      }
      // Always fetch fresh from API
      else {
        final response = await animalCategoryRepo.getAnimalCategory();
        if (response.success == success) {
          animalTypeList.value = response.data ?? [];
          saveAnimalList(animalTypeList);
        }
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
      final cached = await retrieveColorCategory();
      if (cached.isNotEmpty) {
        colorList.value = cached;
      } else {
        final response = await colorCategoryRepo.getColorCategories();
        if (response.success == success) {
          colorList.value = response.data ?? [];
        }
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
        if (Get.isRegistered<InventoryListController>()) {
          Get.find<InventoryListController>().fetchInventoryByTab('shop');
        }
        Get.back(result: true);
        showSnackBar(
          error: response.msg ?? somethingWentMessage,
          isError: false,
        );
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
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
    selectedColors.clear();
    selectedSizes.clear();
    variantCombinations.clear();
  }

  // ── Clothing Matrix helpers ───────────────────────────────────────────────

  void toggleColor(CategoryModelListData colorItem) {
    final exists = selectedColors.any((c) => c.id == colorItem.id);
    if (exists) {
      selectedColors.removeWhere((c) => c.id == colorItem.id);
    } else {
      selectedColors.add(colorItem);
    }
    _regenerateCombinations();
  }

  void toggleSize(CategoryModelListData size) {
    final exists = selectedSizes.any((s) => s.id == size.id);
    if (exists) {
      selectedSizes.removeWhere((s) => s.id == size.id);
    } else {
      selectedSizes.add(size);
    }
    _regenerateCombinations();
  }

  void _regenerateCombinations() {
    final existing = {
      for (final c in variantCombinations) '${c['colorId']}_${c['sizeId']}': c,
    };

    final newCombinations = <Map<String, dynamic>>[];
    for (final colorItem in selectedColors) {
      for (final size in selectedSizes) {
        final key = '${colorItem.id}_${size.id}';
        if (existing.containsKey(key)) {
          newCombinations.add(existing[key]!);
        } else {
          newCombinations.add({
            'colorId': colorItem.id,
            'colorName': colorItem.name ?? '',
            'sizeId': size.id,
            'sizeName': size.name ?? '',
            'barcode': _generateVariantBarcode(
              productName.text,
              colorItem.name ?? '',
              size.name ?? '',
            ),
            'stock': '',
          });
        }
      }
    }
    variantCombinations.value = newCombinations;
  }

  void onProductNameChanged(String _) => _regenerateCombinations();

  String _generateVariantBarcode(
    String name,
    String colorName,
    String sizeName,
  ) {
    String clean(String s) {
      final up = s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      return up.substring(0, up.length.clamp(0, 6));
    }

    // Build an 18-character base from name+color+size (each up to 6 chars)
    final a = clean(name);
    final b = clean(colorName);
    final c = clean(sizeName);
    final combined = (a + b + c).toUpperCase();
    // Take up to 18 characters from combined (no padding with 'X')
    final base = combined.substring(0, combined.length.clamp(0, 18));
    // Fill remaining length with random digits so total == 20
    final needed = 20 - base.length;
    final rand =
        needed > 0
            ? List.generate(
              needed,
              (_) => Random().nextInt(10).toString(),
            ).join()
            : (Random().nextInt(90) + 10).toString();
    return '$base$rand';
  }

  void updateVariantBarcode(int index, String barcodeVal) {
    final updated = Map<String, dynamic>.from(variantCombinations[index]);
    updated['barcode'] = barcodeVal;
    variantCombinations[index] = updated;
  }

  void updateVariantStock(int index, String stock) {
    final updated = Map<String, dynamic>.from(variantCombinations[index]);
    updated['stock'] = stock;
    variantCombinations[index] = updated;
  }

  Future<void> saveProductWithVariants() async {
    if (variantCombinations.isEmpty) {
      showSnackBar(error: 'Please select at least one color and size.');
      return;
    }
    if (productName.text.trim().isEmpty) {
      showSnackBar(error: 'Please enter product name.');
      return;
    }
    if (sellingPrice.text.trim().isEmpty) {
      showSnackBar(error: 'Please enter selling price.');
      return;
    }

    // Stock validation
    for (final v in variantCombinations) {
      final stockStr = v['stock']?.toString().trim() ?? '';
      if (stockStr.isEmpty) {
        showSnackBar(
          error: 'Please enter stock for ${v['colorName']} - ${v['sizeName']}',
        );
        return;
      }
      if ((int.tryParse(stockStr) ?? -1) < 0) {
        showSnackBar(
          error: 'Invalid stock for ${v['colorName']} - ${v['sizeName']}',
        );
        return;
      }
    }

    isSavingVariants.value = true;
    try {
      final variantsArray =
          variantCombinations.map((v) {
            final sizeName = v['sizeName'] ?? '';
            final colorName = v['colorName'] ?? '';
            final variantName =
                sizeName.isNotEmpty
                    ? '${productName.text.trim()} [$colorName - $sizeName]'
                    : '${productName.text.trim()} [$colorName]';
            return {
              "name": variantName,
              "color_id": v['colorId'] ?? '',
              "animal_type": v['sizeId'] ?? '',
              "barcode": v['barcode'] ?? '',
              "quantity": int.tryParse(v['stock']?.toString() ?? '0') ?? 0,
              "selling_price": double.tryParse(sellingPrice.text) ?? 0.0,
              "purchase_price": double.tryParse(purchasePrice.text) ?? 0.0,
            };
          }).toList();

      final body = {
        "name": productName.text.trim(),
        "selling_price": double.tryParse(sellingPrice.text) ?? 0.0,
        "purchase_price": double.tryParse(purchasePrice.text) ?? 0.0,
        "location": location.text.toLowerCase(),
        "stock_type": "clothing",
        "category": selectedCategoryId.value ?? '',
        "brand": brandType.value,
        "level": level.text,
        "rack": rack.text,
        "discount": discount.text,
        "purchase_date": parseAppDate(purchaseDate.text),
        "variants": variantsArray,
      };

      AppLogger.info('=== GENERATE BARCODE CLOTHING VARIANTS BODY ===');
      AppLogger.info(body.toString());

      final response = await productRepo.addProduct(body: body);
      if (response.success == success) {
        if (Get.isRegistered<InventoryListController>()) {
          Get.find<InventoryListController>().fetchInventoryByTab('shop');
        }
        clear();
        Get.back(result: true);
        showMessage(
          message:
              '${variantsArray.length} variant${variantsArray.length > 1 ? 's' : ''} saved successfully!',
        );
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isSavingVariants.value = false;
    }
  }
}
