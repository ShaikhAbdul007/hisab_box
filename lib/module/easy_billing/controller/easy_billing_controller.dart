import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/category/repo/category_repo.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/module/inventorylist/repo/inventory_repo.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';

class EasyBillingController extends GetxController with CacheManager {
  final CategoryRepo _categoryRepo = CategoryRepo();
  final InventoryRepo _inventoryRepo = InventoryRepo();

  // State flags
  RxBool isLoadingCategories = false.obs;
  RxBool isLoadingProducts = false.obs;

  // Category data
  RxList<CategoryModelListData> categoryList = <CategoryModelListData>[].obs;
  RxString selectedCategoryName = 'All'.obs;

  // Product data
  RxList<InventoryItem> allProducts = <InventoryItem>[].obs;
  RxList<InventoryItem> filteredProducts = <InventoryItem>[].obs;

  // Search
  TextEditingController searchController = TextEditingController();
  RxString searchText = ''.obs;

  // Selected Cart Items (Map key -> quantity & item details)
  RxMap<String, int> itemQuantities = <String, int>{}.obs;
  RxMap<String, InventoryItem> selectedProductsMap = <String, InventoryItem>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    await fetchCategories();
    await fetchProducts();
  }

  /// Fetch Categories from backend/local cache
  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    try {
      final response = await _categoryRepo.getCategory();
      if (response.success == success && (response.data?.isNotEmpty ?? false)) {
        categoryList.assignAll(response.data ?? []);
        saveCategoryList(categoryList);
      } else {
        final cached = await retrieveCategory();
        if (cached.isNotEmpty) {
          categoryList.assignAll(cached);
        } else {
          // Default Sample Categories if empty
          categoryList.assignAll([
            CategoryModelListData(id: 'cat_1', name: 'General'),
            CategoryModelListData(id: 'cat_2', name: 'Snacks'),
            CategoryModelListData(id: 'cat_3', name: 'Beverages'),
            CategoryModelListData(id: 'cat_4', name: 'Grocery'),
          ]);
        }
      }
    } catch (e) {
      final cached = await retrieveCategory();
      if (cached.isNotEmpty) {
        categoryList.assignAll(cached);
      } else {
        categoryList.assignAll([
          CategoryModelListData(id: 'cat_1', name: 'General'),
          CategoryModelListData(id: 'cat_2', name: 'Snacks'),
          CategoryModelListData(id: 'cat_3', name: 'Beverages'),
          CategoryModelListData(id: 'cat_4', name: 'Grocery'),
        ]);
      }
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Fetch Products from inventory (with Option 4: Sample Items Fallback)
  Future<void> fetchProducts() async {
    isLoadingProducts.value = true;
    try {
      final response = await _inventoryRepo.getProductData(
        search: 'shop',
        page: 1,
        limit: 200,
      );
      if (response.success == success && (response.data?.data?.isNotEmpty ?? false)) {
        allProducts.assignAll(response.data?.data ?? []);
      } else {
        // Option 4: Sample Preset Items when inventory has no products
        _loadSampleProductsFallback();
      }
    } catch (e) {
      _loadSampleProductsFallback();
    } finally {
      filterProducts();
      isLoadingProducts.value = false;
    }
  }

  /// Option 4: Sample products loaded when database is empty
  void _loadSampleProductsFallback() {
    allProducts.assignAll([
      InventoryItem(
        id: 'sample_1',
        name: 'General Item ₹10',
        sellingPrice: '10',
        quantity: '999',
        categoryName: 'General',
      ),
      InventoryItem(
        id: 'sample_2',
        name: 'General Item ₹50',
        sellingPrice: '50',
        quantity: '999',
        categoryName: 'General',
      ),
      InventoryItem(
        id: 'sample_3',
        name: 'General Item ₹100',
        sellingPrice: '100',
        quantity: '999',
        categoryName: 'General',
      ),
      InventoryItem(
        id: 'sample_4',
        name: 'Tea / Coffee',
        sellingPrice: '20',
        quantity: '999',
        categoryName: 'Beverages',
      ),
      InventoryItem(
        id: 'sample_5',
        name: 'Mineral Water Bottle',
        sellingPrice: '15',
        quantity: '999',
        categoryName: 'Beverages',
      ),
      InventoryItem(
        id: 'sample_6',
        name: 'Snack Pack',
        sellingPrice: '30',
        quantity: '999',
        categoryName: 'Snacks',
      ),
    ]);
  }

  /// Select a Category from sidebar
  void selectCategory(String categoryName) {
    selectedCategoryName.value = categoryName;
    filterProducts();
  }

  /// Filter products by selected category and search query
  void filterProducts() {
    final query = searchText.value.trim().toLowerCase();
    final category = selectedCategoryName.value;

    filteredProducts.assignAll(
      allProducts.where((item) {
        final matchesCategory =
            (category == 'All') ||
            (item.categoryName?.trim().toLowerCase() == category.toLowerCase());

        final matchesSearch =
            query.isEmpty ||
            (item.name?.toLowerCase().contains(query) ?? false) ||
            (item.barcode?.toLowerCase().contains(query) ?? false);

        return matchesCategory && matchesSearch;
      }).toList(),
    );
  }

  /// OPTION 1: Add Custom Item on the fly (Directly into cart without inventory setup)
  void addCustomItem({required String name, required double price, int quantity = 1}) {
    final customId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final customItem = InventoryItem(
      id: customId,
      name: name.isEmpty ? 'Custom Item (₹${price.toStringAsFixed(0)})' : name,
      sellingPrice: price.toString(),
      quantity: '999',
      categoryName: selectedCategoryName.value == 'All' ? 'Custom' : selectedCategoryName.value,
    );

    itemQuantities[customId] = quantity;
    selectedProductsMap[customId] = customItem;
    itemQuantities.refresh();
    selectedProductsMap.refresh();

    showSnackBar(error: 'Added Custom Item ₹${price.toStringAsFixed(2)} to cart', isError: false);
  }

  /// OPTION 2: Quick Add Minimal Product (Saves product to inventory list)
  void addQuickProduct({required String name, required double price, required String categoryName}) {
    final newId = 'quick_${DateTime.now().millisecondsSinceEpoch}';
    final newItem = InventoryItem(
      id: newId,
      name: name,
      sellingPrice: price.toString(),
      quantity: '100',
      categoryName: categoryName.isEmpty ? 'General' : categoryName,
    );

    allProducts.insert(0, newItem);
    filterProducts();
    incrementItem(newItem);

    showSnackBar(error: 'Added product "$name" successfully', isError: false);
  }

  /// Generate unique key for an inventory item
  String getItemKey(InventoryItem item) {
    return item.id ?? item.barcode ?? item.name ?? '';
  }

  /// Increment quantity for a product
  void incrementItem(InventoryItem item) {
    final key = getItemKey(item);
    if (key.isEmpty) return;

    final currentQty = itemQuantities[key] ?? 0;
    final maxStock = double.tryParse(item.quantity ?? '99999') ?? 99999;

    if (currentQty + 1 > maxStock) {
      showSnackBar(error: 'Stock limit reached for ${item.name}');
      return;
    }

    itemQuantities[key] = currentQty + 1;
    selectedProductsMap[key] = item;
    itemQuantities.refresh();
    selectedProductsMap.refresh();
  }

  /// Decrement quantity for a product
  void decrementItem(InventoryItem item) {
    final key = getItemKey(item);
    if (key.isEmpty) return;

    final currentQty = itemQuantities[key] ?? 0;
    if (currentQty <= 1) {
      itemQuantities.remove(key);
      selectedProductsMap.remove(key);
    } else {
      itemQuantities[key] = currentQty - 1;
    }
    itemQuantities.refresh();
    selectedProductsMap.refresh();
  }

  /// Get quantity count for a product
  int getItemQuantity(InventoryItem item) {
    final key = getItemKey(item);
    return itemQuantities[key] ?? 0;
  }

  /// Total selected item count
  int get totalSelectedCount {
    int total = 0;
    for (var qty in itemQuantities.values) {
      total += qty;
    }
    return total;
  }

  /// Total bill amount
  double get totalAmount {
    double total = 0.0;
    selectedProductsMap.forEach((key, item) {
      final qty = itemQuantities[key] ?? 0;
      final price = double.tryParse(item.sellingPrice ?? '0') ?? 0.0;
      total += (price * qty);
    });
    return total;
  }

  /// Clear current cart selection
  void clearCart() {
    itemQuantities.clear();
    selectedProductsMap.clear();
  }

  /// Save selected items to Cart and Navigate to SellListAfterScan
  Future<void> proceedToCheckout() async {
    if (selectedProductsMap.isEmpty) {
      showSnackBar(error: 'Please select at least one product');
      return;
    }

    List<InventoryItem> checkoutList = [];
    selectedProductsMap.forEach((key, item) {
      final qty = itemQuantities[key] ?? 1;
      final itemCopy = InventoryItem.fromJson(item.toJson());
      itemCopy.quantity = qty.toString();
      checkoutList.add(itemCopy);
    });

    // Save cart items to local storage cache
    saveCartProductList(checkoutList);

    // Navigate to SellListAfterScan screen
    AppRoutes.navigateRoutes(
      routeName: AppRouteName.sellListAfterScan,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
