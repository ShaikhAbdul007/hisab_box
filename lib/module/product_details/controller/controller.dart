import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'dart:math';
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

  // ── Clothing Matrix: multi-select colors + sizes ──────────────────────────
  RxList<CategoryModelListData> selectedColors = <CategoryModelListData>[].obs;
  RxList<CategoryModelListData> selectedSizes = <CategoryModelListData>[].obs;

  // Each combination: { colorId, colorName, sizeId, sizeName, barcode, stock }
  RxList<Map<String, dynamic>> variantCombinations =
      <Map<String, dynamic>>[].obs;
  RxBool isSavingVariants = false.obs;

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
  RxBool isLocationLocked = false.obs;
  RxBool isLoose = false.obs;
  RxBool isProductDataExist = false.obs;

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
    _prefillFromExistingProduct(); // pre-fill if cross-location copy
    super.onInit();
  }

  /// Pre-fills form with data from an existing product when creating a
  /// cross-location copy (e.g. Shop → Godown or Godown → Shop).
  void _prefillFromExistingProduct() {
    final existing = data['existingProduct'];
    if (existing == null || existing is! Map) return;
    isProductDataExist.value = true;
    final Map<String, dynamic> p = Map<String, dynamic>.from(existing);
    AppLogger.info("Prefilling form with existing product data: $p");
    isLoose.value = p['isLoosed'];
    AppLogger.info("isLoosed product data: $isLoose");

    productName.text = p['name']?.toString() ?? '';
    sellingPrice.text = p['sellingPrice']?.toString() ?? '';
    purchasePrice.text = p['purchasePrice']?.toString() ?? '';
    discount.text = p['discount']?.toString() ?? '0';
    flavor.text = p['flavour']?.toString() ?? '';
    weight.text = p['weight']?.toString() ?? '';
    brandType.value = p['brand']?.toString() ?? '';
    level.text = p['level']?.toString() ?? '';
    rack.text = p['rack']?.toString() ?? '';
    isFlavorAndWeightNotRequired.value =
        p['isFlavorRequired'] as bool? ?? false;

    final categoryName = p['categoryName']?.toString() ?? '';
    final categoryId = p['categoryId']?.toString();
    if (categoryName.isNotEmpty) {
      category.text = categoryName;
      if (categoryId != null) selectedCategoryId.value = categoryId;
    }

    final animalName = p['animalTypeName']?.toString() ?? '';
    final animalId = p['animalTypeId']?.toString();
    if (animalName.isNotEmpty) {
      animalType.text = animalName;
      if (animalId != null) selectedAnimalTypeId.value = animalId;
    }

    final colorName = p['colorName']?.toString() ?? '';
    final colorId = p['colorId']?.toString();
    if (colorName.isNotEmpty) {
      color.text = colorName;
      if (colorId != null) selectedColorId.value = colorId;
    }

    if ((p['expireDate']?.toString() ?? '').isNotEmpty) {
      String rawDate = p['expireDate'].toString();
      String formatted = formatDateTime(rawDate);
      exprieDate.text = formatted;
    }
    if ((p['purchaseDate']?.toString() ?? '').isNotEmpty) {
      String rawDate = p['purchaseDate'].toString();
      String formatted = formatDateTime(rawDate);
      purchaseDate.text = formatted;
    }
  }

  Future<void> retrieveGodownValue() async {
    final isGodownEnabled = await retrieveGodown();
    locationOptions.value =
        isGodownEnabled ? <String>['Shop', 'Godown'] : <String>['Shop'];
    final preferredLocation = (data['preferredLocation'] ?? '').toString();
    final normalizedPreferred = preferredLocation.toLowerCase();
    if (normalizedPreferred == 'shop' && locationOptions.contains('Shop')) {
      isLocationLocked.value = true;
      location.text = 'Shop';
      return;
    }
    if (normalizedPreferred == 'godown' && locationOptions.contains('Godown')) {
      isLocationLocked.value = true;
      location.text = 'Godown';
      return;
    }
    isLocationLocked.value = false;
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
        categoryList.value = response.data ?? [];
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
        animalTypeList.value = response.data ?? [];
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
        colorList.value = response.data ?? [];
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

  Future<void> saveNewLooseProduct({required dynamic body}) async {
    isLooseProductSave.value = true;
    try {
      var response = await productRepo.addLoosedProduct(body: body);
      if (response.success == success) {
        clear();
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
          message:
              response.data?.message ?? response.msg ?? somethingWentMessage,
        );
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
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
    selectedColors.clear();
    selectedSizes.clear();
    variantCombinations.clear();
  }

  // ── Clothing Matrix helpers ───────────────────────────────────────────────

  /// Toggle a color in selectedColors. Regenerates combinations after.
  void toggleColor(CategoryModelListData color) {
    final exists = selectedColors.any((c) => c.id == color.id);
    if (exists) {
      selectedColors.removeWhere((c) => c.id == color.id);
    } else {
      selectedColors.add(color);
    }
    _regenerateCombinations();
  }

  /// Toggle a size in selectedSizes. Regenerates combinations after.
  void toggleSize(CategoryModelListData size) {
    final exists = selectedSizes.any((s) => s.id == size.id);
    if (exists) {
      selectedSizes.removeWhere((s) => s.id == size.id);
    } else {
      selectedSizes.add(size);
    }
    _regenerateCombinations();
  }

  /// Auto-generates Color × Size combinations preserving existing stock/barcode edits.
  void _regenerateCombinations() {
    final existing = {
      for (final c in variantCombinations) '${c['colorId']}_${c['sizeId']}': c,
    };

    final newCombinations = <Map<String, dynamic>>[];
    for (final color in selectedColors) {
      for (final size in selectedSizes) {
        final key = '${color.id}_${size.id}';
        if (existing.containsKey(key)) {
          // Preserve user-edited stock and barcode
          newCombinations.add(existing[key]!);
        } else {
          final autoBarcode = _generateBarcode(
            productName.text,
            color.name ?? '',
            size.name ?? '',
          );
          newCombinations.add({
            'colorId': color.id,
            'colorName': color.name ?? '',
            'sizeId': size.id,
            'sizeName': size.name ?? '',
            'barcode': autoBarcode,
            'stock': '',
          });
        }
      }
    }
    variantCombinations.value = newCombinations;
  }

  /// Regenerates barcodes when product name changes (only for unedited ones).
  void onProductNameChanged(String _) {
    _regenerateCombinations();
  }

  String _generateBarcode(String name, String color, String size) {
    String clean(String s) {
      final up = s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
      return up.substring(0, up.length.clamp(0, 6));
    }

    final a = clean(name);
    final b = clean(color);
    final c = clean(size);
    final combined = (a + b + c).toUpperCase();
    final base = combined.substring(0, combined.length.clamp(0, 18));
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

  void updateVariantBarcode(int index, String barcode) {
    final updated = Map<String, dynamic>.from(variantCombinations[index]);
    updated['barcode'] = barcode;
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

    // ── Stock validation — all variants must have stock ───────────────────
    for (int i = 0; i < variantCombinations.length; i++) {
      final v = variantCombinations[i];
      final stockStr = v['stock']?.toString().trim() ?? '';
      if (stockStr.isEmpty) {
        showSnackBar(
          error: 'Please enter stock for ${v['colorName']} - ${v['sizeName']}',
        );
        return;
      }
      final stockVal = int.tryParse(stockStr);
      if (stockVal == null || stockVal < 0) {
        showSnackBar(
          error: 'Invalid stock for ${v['colorName']} - ${v['sizeName']}',
        );
        return;
      }
    }

    isSavingVariants.value = true;

    try {
      // Build variants array
      final List<Map<String, dynamic>> variantsArray =
          variantCombinations.map((v) {
            final colorName = v['colorName'] ?? '';
            final sizeName = v['sizeName'] ?? '';
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

      // Debug: print body on save
      AppLogger.info('=== CLOTHING VARIANTS BODY ===');
      AppLogger.info(body.toString());

      final response = await productRepo.addProduct(body: body);
      if (response.success == success) {
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
