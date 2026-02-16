import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import '../../inventory/model/product_model.dart';

class NearExpireProductController extends GetxController with CacheManager {
  final String? uid = SupabaseConfig.auth.currentUser?.id;
  RxList<ProductModel> nearExpProductList = <ProductModel>[].obs;
  RxBool isDataloading = false.obs;

  @override
  void onInit() {
    getNearExpiryProducts();
    super.onInit();
  }

  Future<void> getNearExpiryProducts() async {
    if (uid == null) return;
    isDataloading.value = true;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final threeMonthsFromNow = now.add(const Duration(days: 90));

      // 🎯 Query: stock_batches se start, products join, aur product_stock se price
      final response = await SupabaseConfig.from('stock_batches')
          .select('''
          id,
          expiry_date,
          purchase_date,
          purchase_price,
          quantity,
          location,
          stock_type,
          products (
            id, name, flavour, weight, rack, level,
            categories(name),
            animal_categories(name),
            product_barcodes(barcode),
            product_stock (
              selling_price
            )
          )
        ''')
          .eq('user_id', uid!)
          .filter('expiry_date', 'gte', today.toIso8601String())
          .filter('expiry_date', 'lte', threeMonthsFromNow.toIso8601String());

      final List dataList = response as List;
      List<ProductModel> expiryProducts = [];

      for (var batch in dataList) {
        final productData = batch['products'];
        if (productData == null) continue;

        // Product stock se selling price nikalna (Location ignore karke)
        final stockList = productData['product_stock'] as List?;
        final sellingPrice =
            (stockList != null && stockList.isNotEmpty)
                ? (stockList[0]['selling_price'] ?? 0.0)
                : 0.0;

        final Map<String, dynamic> productMap = Map<String, dynamic>.from(
          productData,
        );

        // --- Batch & Location Data ---
        productMap['purchase_date'] = batch['purchase_date'];
        productMap['expiry_date'] = batch['expiry_date'];
        productMap['purchase_price'] =
            (batch['purchase_price'] ?? 0).toDouble();
        productMap['quantity'] = (batch['quantity'] ?? 0).toDouble();
        productMap['location'] =
            batch['location'] ?? 'N/A'; // Shop or Godown dono aayenge
        productMap['stock_type'] = batch['stock_type'] ?? 'packet';

        // --- Prices & Mapping ---
        productMap['selling_price'] = sellingPrice.toDouble();
        productMap['sellingPrice'] =
            sellingPrice.toDouble(); // Model compatibility

        // --- Meta Data ---
        productMap['category'] = productData['categories']?['name'] ?? '';
        productMap['animal_type'] =
            productData['animal_categories']?['name'] ?? '';

        final barcodes = productData['product_barcodes'] as List?;
        productMap['barcode'] =
            (barcodes != null && barcodes.isNotEmpty)
                ? barcodes[0]['barcode']
                : '';

        // --- Date Compatibility ---
        productMap['purchaseDate'] = batch['purchase_date'];
        productMap['expireDate'] = batch['expiry_date'];

        expiryProducts.add(ProductModel.fromJson(productMap));
      }

      // Sort by date
      expiryProducts.sort((a, b) {
        DateTime dateA =
            DateTime.tryParse(a.expireDate ?? '') ?? DateTime(2100);
        DateTime dateB =
            DateTime.tryParse(b.expireDate ?? '') ?? DateTime(2100);
        return dateA.compareTo(dateB);
      });

      nearExpProductList.value = expiryProducts;
      print("✅ Total Expiry Items: ${nearExpProductList.length}");
    } catch (e) {
      print("🚨 Expiry Fetch Error: $e");
    } finally {
      isDataloading.value = false;
    }
  }

  // Helper method sorting ke liye
  // DateTime _parseDate(String dateStr) {
  //   try {
  //     if (dateStr.split('-')[0].length == 4) return DateTime.parse(dateStr);
  //     return DateFormat('dd-MM-yyyy').parse(dateStr);
  //   } catch (_) {
  //     return DateTime(2099); // Fallback for sorting
  //   }
  // }
}
