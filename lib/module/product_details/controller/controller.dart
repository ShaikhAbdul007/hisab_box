import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import '../../../helper/helper.dart';
import '../../category/model/category_model.dart';
import '../../inventory/model/product_model.dart';

class ProductController extends GetxController with CacheManager {
  final uid = SupabaseConfig.auth.currentUser?.id;
  // 🔥 Supabase Config use kar rahe hain
  final inventoryScanKey = GlobalKey<FormState>();
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  var productList = <ProductModel>[].obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;
  RxList<ProductModel> looseCatogorieList = <ProductModel>[].obs;
  RxList<ProductModel> looseInventoryLis = <ProductModel>[].obs;
  RxList<ProductModel> fullLooseSellingList = <ProductModel>[].obs;

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
  RxString dayDate = ''.obs;
  bool isLoose = false;
  var data = Get.arguments;

  @override
  void onInit() async {
    dayDate.value = setFormateDate();
    setLoosedProduct();
    setBarcode();
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
    barcode.text = data['barcode'];
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

  // ================================
  // 🔥 FETCH CATEGORIES (SUPABASE)
  // ================================
  Future<void> fetchCategories() async {
    var categorList = await retrieveCategoryModel();
    if (categorList.isNotEmpty) {
      categoryList.value = categorList;
    } else {
      if (uid == null) return;

      try {
        final response = await SupabaseConfig.from(
          'categories',
        ).select().eq('user_id', uid ?? '');

        categoryList.value =
            (response as List).map((e) => CategoryModel.fromJson(e)).toList();
        saveCategoryModel(categoryList);
      } catch (e) {
        showMessage(message: e.toString());
      }
    }
  }

  // ================================
  // 🔥 FETCH ANIMAL CATEGORIES (SUPABASE)
  // ================================
  Future<void> fetchAnimalCategories() async {
    var animalCategorList = await retrieveAnimalCategoryModel();
    if (animalCategorList.isNotEmpty) {
      animalTypeList.value = animalCategorList;
    } else {
      if (uid == null) return;
      try {
        final response = await SupabaseConfig.from(
          'animal_categories',
        ).select().eq('user_id', uid ?? '');

        animalTypeList.value =
            (response as List).map((e) => CategoryModel.fromJson(e)).toList();
        saveAnimalCategoryModel(animalTypeList);
      } catch (e) {
        showMessage(message: e.toString());
      }
    }
  }

  String getRandomHexColor() {
    final random = Random();
    final color = (random.nextDouble() * 0xFFFFFF).toInt();
    return '0xff${color.toRadixString(16).padLeft(6, '0')}';
  }

  // ================================
  // 🔥 SAVE NEW PRODUCT (MULTI-TABLE INSERT)
  // ================================
  Future<void> saveNewProduct({required String barcode}) async {
    isSaveLoading.value = true;
    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) return;

      // 1️⃣ Check Barcode for Multiple Barcodes Support [cite: 2026-01-31]
      final existingBarcode =
          await SupabaseConfig.from(
            'product_barcodes',
          ).select('product_id').eq('barcode', barcode).maybeSingle();

      String productId;

      if (existingBarcode != null) {
        productId = existingBarcode['product_id'];
      } else {
        // 🆕 PRODUCTS Table Insert
        final productResponse =
            await SupabaseConfig.from('products')
                .insert({
                  'user_id': uid,
                  'name': productName.text,
                  'category': category.text,
                  'animal_type': animalType.text,
                  'flavour': flavor.text,
                  'level': level.text,
                  'rack': rack.text,
                  'weight': weight.text,
                  'is_loose_category': isLoose,
                  'is_flavor_and_weight_not_required':
                      isFlavorAndWeightNotRequired.value,
                })
                .select()
                .single();

        productId = productResponse['id'];

        // BARCODE Insert
        await SupabaseConfig.from(
          'product_barcodes',
        ).insert({'product_id': productId, 'barcode': barcode});
      }

      final String targetLoc =
          location.text.toLowerCase() == 'godown' ? 'godown' : 'shop';
      final int qty = int.tryParse(quantity.text) ?? 0;
      final double sPrice = double.tryParse(sellingPrice.text) ?? 0.0;
      final double pPrice = double.tryParse(purchasePrice.text) ?? 0.0;
      final double discAmt = double.tryParse(discount.text) ?? 0.0;
      final String stockType = 'packet';
      // 2️⃣ STOCK_BATCHES Insert (Date type columns)
      await SupabaseConfig.from('stock_batches').insert({
        'user_id': uid,
        'product_id': productId,
        'location': targetLoc,
        'stock_type': stockType,
        'purchase_price': pPrice,
        'purchase_date': formatDateForDB(purchaseDate.text),
        'expiry_date': formatDateForDB(exprieDate.text),
        'quantity': qty,
        'level': level.text,
        'rack': rack.text,
      });

      // 3️⃣ STOCK_MOVEMENTS Insert (Using 'form_location' as per your schema)
      await SupabaseConfig.from('stock_movements').insert({
        'product_id': productId,
        'user_id': uid,
        'form_location': targetLoc,
        'to_location': targetLoc,
        'stock_type': stockType,
        'movement_type': 'add',
        'quantity': qty,
        'price': sPrice,
        'discount_percent': discAmt,
        'final_price': sPrice - discAmt,
        'reason': 'Initial Stock Entry',
      });

      // 4️⃣ PRODUCT_STOCK Insert (Insert only as per your rule)
      await SupabaseConfig.from('product_stock').insert({
        'product_id': productId,
        'user_id': uid,
        'location': targetLoc,
        'stock_type': stockType,
        'quantity': qty,
        'selling_price': sPrice,
        'discount': discAmt.toString(), // Schema says 'text' for discount
        'is_active': true,
      });

      showMessage(message: "✅ Product and Stock added successfully!");
      clear();
      Get.back(result: true);
    } catch (e) {
      print("Insert Error: $e");
      showMessage(message: "❌ Error: $e");
    } finally {
      isSaveLoading.value = false;
    }
  }

  // ==========================================
  // 🔥 SAVE NEW LOOSE PRODUCT (STOCK CONVERSION)
  // ==========================================
  Future<void> saveNewLooseProduct({required String barcode}) async {
    isLooseProductSave.value = true;

    final uid = SupabaseConfig.auth.currentUser?.id;
    if (uid == null) {
      isLooseProductSave.value = false;
      return;
    }

    try {
      // 1️⃣ Barcode scan karke Product aur Shop Stock nikaalo
      final response =
          await SupabaseConfig.from('product_barcodes')
              .select('''
          product_id,
          products!inner (
            name,
            is_loose_category, 
            product_stock!product_stock_product_id_fkey!inner (
              id,
              quantity,
              location,
              stock_type
            )
          )
        ''')
              .eq('barcode', barcode)
              .maybeSingle();

      if (response == null) {
        showMessage(message: "❌ Product shop mein nahi mila!");
        return;
      }

      final String pId = response['product_id'];
      final productData = response['products'];
      final List stockList = productData['product_stock'] ?? [];

      // Specifically 'shop' aur 'packet' dhoondo
      final packetEntry = stockList.firstWhere(
        (s) => s['location'] == 'shop' && s['stock_type'] == 'packet',
        orElse: () => null,
      );

      // --- VALIDATIONS ---
      if (packetEntry == null || (packetEntry['quantity'] ?? 0) <= 0) {
        showMessage(message: "❌ Shop mein packet stock khatam hai!");
        return;
      }

      // [cite: 2026-01-31] Check if loose is allowed
      if (productData['is_loose_category'] != true) {
        showMessage(message: "❌ Ye product loose bechna mana hai!");
        return;
      }

      // 2️⃣ EXECUTION (No Upsert, Only Insert in Loose Table)

      // A. Purane Packet Table se -1 Quantity update karo
      await SupabaseConfig.from('product_stock')
          .update({'quantity': (packetEntry['quantity'] ?? 0) - 1})
          .eq('id', packetEntry['id']);

      // B. Naya Record Loose Table mein INSERT karo (No Update/Upsert here)
      // Har baar naya packet khulne par naya row banega
      await SupabaseConfig.from('loose_stocks').insert({
        'product_id': pId,
        'user_id': uid,
        'quantity': int.tryParse(looseQuantity.text) ?? 0,
        'selling_price': double.tryParse(sellingPrice.text) ?? 0.0,
        // 'location' is table mein shop hi hogi by default
      });

      // C. History log maintain karo
      await SupabaseConfig.from('stock_movements').insert({
        'product_id': pId,
        'user_id': uid,
        'form_location': 'shop',
        'stock_type': 'packet',
        'movement_type': 'packet_to_loose',
        'quantity': -1,
        'reason': '1 Packet split into ${quantity.text} pieces',
      });

      showMessage(message: "✅ Naya Loose Stock Add ho gaya!");

      clear();

      Get.back(result: true);
    } catch (e) {
      print("Error: $e");
      showMessage(message: "❌ Kuch gadat hua, retry kar!");
    } finally {
      isLooseProductSave.value = false;
    }
  }

  Future<void> fetchAllProducts() async {
    if (uid == null) return;

    final response = await SupabaseConfig.from('products')
        .select('*, product_stock!inner(*)')
        .eq('user_id', uid ?? '')
        .eq('product_stock.is_active', true);

    productList.value =
        (response as List).map((e) => ProductModel.fromJson(e)).toList();
    saveProductList(productList);
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
}
