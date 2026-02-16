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

      // 1️⃣ Check karo ki fields empty toh nahi hain
      if (category.text.isEmpty || animalType.text.isEmpty) {
        showMessage(
          message: "❌ Category aur Animal Type select karna zaroori hai!",
        );
        return;
      }

      // 2️⃣ RPC Call: Direct .text bhejo kyunki usme ID hi hai
      await SupabaseConfig.client.rpc(
        'add_new_product_with_stock',
        params: {
          'p_user_id': uid,
          'p_name': productName.text.trim(),
          'p_category': category.text.trim(), // '550e8400-e2...' jaisi ID
          'p_animal_type': animalType.text.trim(),
          'p_flavor': flavor.text,
          'p_level': level.text,
          'p_rack': rack.text,
          'p_weight': weight.text,
          'p_is_loose': isLoose, // RxBool hai toh .value zaroor lagayein
          'p_barcode': barcode,
          'p_qty': num.tryParse(quantity.text) ?? 0,
          'p_s_price': double.tryParse(sellingPrice.text) ?? 0.0,
          'p_p_price': double.tryParse(purchasePrice.text) ?? 0.0,
          'p_disc_amt': double.tryParse(discount.text) ?? 0.0,
          'p_purchase_date': formatDateForDB(purchaseDate.text),
          'p_expiry_date': formatDateForDB(exprieDate.text),
          'p_location':
              location.text.toLowerCase().contains('godown')
                  ? 'godown'
                  : 'shop',
        },
      );

      showMessage(message: "✅ Product successfully save ho gaya!");
      clear();
      Get.back(result: true);
    } catch (e) {
      print("🚨 Transaction Error Detail: $e");
      // Agar ab bhi UUID error aaye, toh iska matlab SQL function mein cast ki kami hai
      showMessage(message: "❌ Database Error: $e");
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
      showMessage(message: "❌ User session expired. Please login again.");
      isLooseProductSave.value = false;
      return;
    }

    // Input Validation
    if (looseQuantity.text.isEmpty || sellingPrice.text.isEmpty) {
      showMessage(message: "❌ Please enter loose quantity and selling price.");
      isLooseProductSave.value = false;
      return;
    }

    try {
      // 1️⃣ Fetch Product and Stock details
      final response =
          await SupabaseConfig.client
              .from('product_barcodes')
              .select('''
          product_id,
          products (
            is_loose_category,
            product_stock (
              id, 
              quantity, 
              location, 
              stock_type,
              user_id
            )
          )
        ''')
              .eq('barcode', barcode)
              .maybeSingle();

      if (response == null || response['products'] == null) {
        showMessage(message: "❌ Product ya Barcode system mein nahi mila!");
        return;
      }

      final String pId = response['product_id'];
      final productData = response['products'];
      final List stockList = productData['product_stock'] ?? [];

      // 2️⃣ Filtering: Shop mein Packet Stock dhoondo
      // Database schema ke hisaab se 'packet' aur 'shop' exact match hone chahiye
      final packetEntry = stockList.firstWhereOrNull(
        (s) =>
            s['location'].toString().toLowerCase().trim() == 'shop' &&
            s['stock_type'].toString().toLowerCase().trim() == 'packet' &&
            s['user_id'] == uid,
      );

      // 3️⃣ Validations
      if (packetEntry == null) {
        showMessage(
          message: "❌ Is product ka Shop mein 'Packet' stock nahi mila!",
        );
        return;
      }

      if ((packetEntry['quantity'] ?? 0) <= 0) {
        showMessage(message: "❌ Shop mein packet stock khatam ho gaya hai!");
        return;
      }

      if (productData['is_loose_category'] != true) {
        showMessage(message: "❌ Ye product loose bechna allowed nahi hai!");
        return;
      }

      // 4️⃣ EXECUTION: Database Transaction Call
      // p_loose_qty ko 'num' rakha hai taaki SQL ke NUMERIC type se match kare
      await SupabaseConfig.client.rpc(
        'convert_packet_to_loose',
        params: {
          'p_user_id': uid,
          'p_product_id': pId,
          'p_packet_stock_id': packetEntry['id'],
          'p_loose_qty': num.tryParse(looseQuantity.text) ?? 0,
          'p_selling_price': double.tryParse(sellingPrice.text) ?? 0.0,
          'p_reason':
              '1 Packet converted to ${looseQuantity.text} loose pieces',
        },
      );

      showMessage(message: "✅ Packet successfully converted to Loose!");

      // UI Cleanup
      clear(); // Aapka controller clear method
      Get.back(result: true); // Screen band karke refresh trigger karega
    } catch (e) {
      print("🚨 Conversion Error Details: $e");
      // Hint: Agar yahan 'Multiple Candidates' error aaye, toh wahi DROP SQL chalana hai.
      showMessage(message: "❌ Error: $e");
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
