import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/module/product_details/repo/product_repo.dart';
import '../../../helper/helper.dart';
import '../../../helper/set_format_date.dart';
import '../../category/model/category_model.dart';

class ProductDetailsController extends GetxController with CacheManager {
  ProductRepo productRepo = ProductRepo();
  final inventoryScanKey = GlobalKey<FormState>();
  RxList<CategoryModelListData> categoryList = <CategoryModelListData>[].obs;
  RxList<CategoryModelListData> animalTypeList = <CategoryModelListData>[].obs;
  RxList<LooseInvetoryModel> looseInventoryLis = <LooseInvetoryModel>[].obs;
  TextEditingController transferQuantityToShop = TextEditingController();
  TextEditingController productName = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController looseQuantity = TextEditingController();
  TextEditingController looseSellingPrice = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController animalType = TextEditingController();
  TextEditingController color = TextEditingController();
  TextEditingController brand = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController purchasePrice = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController barcode = TextEditingController();
  TextEditingController loooseProductName = TextEditingController();
  TextEditingController exprieDate = TextEditingController();
  TextEditingController purchaseDate = TextEditingController();
  TextEditingController rack = TextEditingController();
  TextEditingController level = TextEditingController();
  TextEditingController barcodeQytController = TextEditingController();
  RxList<CategoryModel> categoryModel = <CategoryModel>[].obs;

  // Selected dropdown ids (matched against item.id in CustomDropDown)
  RxnString selectedCategoryId = RxnString(null);
  RxnString selectedAnimalTypeId = RxnString(null);

  RxBool isFlavorAndWeightNotRequired = true.obs;
  RxBool isLooseProductSave = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool readOnly = true.obs;
  RxBool dropDownReadOnly = false.obs;
  RxBool isDataLoading = false.obs;
  RxString dayDate = ''.obs;
  RxString productId = ''.obs;
  RxString shopType = ''.obs;
  RxString rxProductName = ''.obs;
  RxString rxQuantity = ''.obs;
  RxString brandType = ''.obs;
  bool isLoose = false;

  ShopType get shopTypeEnum => ShopType.fromString(shopType.value);

  RxBool isTransferLoading = false.obs;
  var data = Get.arguments;

  @override
  void onInit() {
    dayDate.value = setFormateDate();
    getCategoryData();
    print('setdata');
    super.onInit();
  }

  // ==========================================
  // 🔥 STOCK TRANSFER (SUPABASE + SYNC)
  // ==========================================
  Future<void> requestStockTransfer({
    required InventoryItem product,
    required double requestedQty,
  }) async {
    isTransferLoading.value = true;
    try {
      // 🔥 Sirf ek call aur SQL function saara logic handle karega
      // await SupabaseConfig.client.rpc(
      //   'process_stock_transfer',
      //   params: {
      //     'p_user_id': '',
      //     'p_product_id': product.id,
      //     'p_qty': requestedQty,
      //     'p_ref_id': refId,
      //     'p_stock_type': product.stockType ?? 'packet',
      //     'p_price': product.sellingPrice ?? 0.0,
      //     'p_title': "📦 New Stock Incoming!",
      //     'p_body':
      //         "${product.name} ke $requestedQty units Godown se bheje gaye hain.",
      //   },
      // );

      showSnackBar(error: "📤 Transfer Successful & Notification Sent!");

      // UI Update/Refresh logic yahan dal sakte ho (e.g., Get.back())
      Get.back();
    } catch (e) {
      // Agar SQL mein 'RAISE EXCEPTION' hoga toh wo yahan catch hoga
      AppLogger.error("Transfer Error", e, "StockTransfer");

      String errorMsg = "Transfer failed!";
      if (e.toString().contains('Godown mein stock kam hai')) {
        errorMsg = "Godown mein stock kam hai!";
      }

      showSnackBar(error: errorMsg);
    } finally {
      isTransferLoading.value = false;
    }
  }

  void getCategoryData() async {
    isDataLoading.value = true;
    final user = retrieveUserDetail();
    shopType.value = user.data?.shopType ?? '';
    await fetchCategories();
    await fetchAnimalCategories();
    setData();
    isDataLoading.value = false;
  }

  dynamic getCategorySelectedItem(String value) {
    try {
      final match = categoryList.firstWhereOrNull((e) => e.name == value);
      if (match != null) {
        category.text = match.name ?? '';
        selectedCategoryId.value = match.id;
      }
    } catch (e) {
      return null;
    }
  }

  dynamic getAnimalSelectedItem(String value) {
    try {
      final match = animalTypeList.firstWhereOrNull((e) => e.name == value);
      if (match != null) {
        animalType.text = match.name ?? '';
        selectedAnimalTypeId.value = match.id;
      }
    } catch (e) {
      return null;
    }
  }

  void setData() {
    var productData = data['product'];
    if (productData is InventoryItem) {
      InventoryItem p = productData;
      productId.value = p.id ?? '';
      category.text = p.categoryName ?? '';
      animalType.text = p.animalTypeName ?? '';
      isFlavorAndWeightNotRequired.value = p.isflavorRequired ?? false;
      productName.text = p.name ?? '';
      barcode.text = p.barcode ?? '';
      quantity.text = p.quantity.toString();
      barcodeQytController.text = p.quantity.toString();
      rxProductName.value = p.name ?? '';
      rxQuantity.value = p.quantity.toString();
      location.text = p.location ?? '';
      sellingPrice.text = p.sellingPrice.toString();
      purchasePrice.text = p.purchasePrice.toString();
      flavor.text = p.flavour ?? '';
      weight.text = p.weight ?? '';
      rack.text = p.rack ?? '';
      level.text = p.level ?? '';
      color.text = p.color ?? '';
      brand.text = p.brand ?? '';
      brandType.value = p.brandType ?? '';
      isLoose = p.isloosed ?? false;
      discount.text = p.discount.toString();
      purchaseDate.text = p.purchaseDate ?? '';
      exprieDate.text = p.expireDate ?? '';
      getCategorySelectedItem(p.categoryName ?? '');
      getAnimalSelectedItem(p.animalTypeName ?? '');
    } else {
      Map<String, dynamic> p = productData as Map<String, dynamic>;

      isFlavorAndWeightNotRequired.value =
          p['isFlavorAndWeightNotRequired'] ??
          p['is_flavor_and_weight_not_required'] ??
          false;
      productName.text = p['name']?.toString() ?? '';
      barcode.text = p['barcode']?.toString() ?? '';
      quantity.text = p['quantity']?.toString() ?? '0';
      rack.text = p['rack']?.toString() ?? '';
      level.text = p['level']?.toString() ?? '';
      barcodeQytController.text = p['quantity']?.toString() ?? '0';
      rxProductName.value = p['name']?.toString() ?? '';
      rxQuantity.value = p['quantity']?.toString() ?? '0';

      sellingPrice.text = p['sellingPrice']?.toString() ?? '0';
      purchasePrice.text = p['purchasePrice']?.toString() ?? '0';
      flavor.text = p['flavor']?.toString() ?? p['flavour']?.toString() ?? '';
      weight.text = p['weight']?.toString() ?? '';
      color.text = p['color']?.toString() ?? '';
      brand.text = p['brand']?.toString() ?? '';
      brandType.value = p['brand_type']?.toString() ?? '';
      isLoose = p['isLoosed'] ?? false;
      discount.text = p['discount']?.toString() ?? '0';
      purchaseDate.text = p['purchaseDate']?.toString() ?? '';
      exprieDate.text = p['expireDate']?.toString() ?? '';
      getCategorySelectedItem(p['category_name']?.toString() ?? '');
      getAnimalSelectedItem(p['animal_type_name']?.toString() ?? '');
    }
  }

  // ==========================================
  // 🔥 UPDATE: Supabase RPC -> Global Sync -> Hive Update
  // ==========================================
  void updateProductQuantity({
    required dynamic body,

    required String productId,
  }) async {
    isSaveLoading.value = true;

    try {
      var response = await productRepo.updatePacketProduct(
        body: body,
        productId: productId,
      );
      if (response.success == success) {
        showSnackBar(
          error: response.msg ?? "Update SuccessFully!",
          isError: false,
        );
        Get.back(result: true);
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? "Update Failed!");
      } else {
        showSnackBar(error: response.msg ?? "Update Failed!");
      }
    } catch (e) {
      AppLogger.info(("🚨 Update Error: $e").toString());
      showSnackBar(error: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  void updateLoosedProductQuantity({required dynamic body}) async {
    isSaveLoading.value = true;
    try {
      var response = await productRepo.updateLoosePacketProduct(body: body);
      if (response.success == success) {
        showSnackBar(
          error: response.msg ?? "Update SuccessFully!",
          isError: false,
        );
        Get.back(result: true);
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? "Update Failed!");
      } else {
        showSnackBar(error: response.msg ?? "Update Failed!");
      }
    } catch (e) {
      AppLogger.info(("🚨 Update Error: $e").toString());
      showSnackBar(error: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final cached = await retrieveCategory();
      if (cached.isNotEmpty) {
        categoryList.value = cached;
      }
    } catch (e) {
      AppLogger.info(("🚨 Category Error: $e").toString());
      showSnackBar(error: e.toString());
    } finally {
      // categoryListLoading.value = false;
    }
  }

  // 🔥 FETCH ANIMAL CATEGORIES
  Future<void> fetchAnimalCategories() async {
    try {
      var cached = await retrieveAnimalCategory();
      if (cached.isNotEmpty) {
        animalTypeList.value = cached;
      }
    } catch (e) {
      AppLogger.info(("🚨 Animal Error: $e").toString());
      showSnackBar(error: e.toString());
    } finally {
      // animalCategoryListLoading.value = false;
    }
  }
}
