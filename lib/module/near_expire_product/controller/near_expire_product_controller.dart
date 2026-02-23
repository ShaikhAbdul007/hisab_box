import 'package:get/get.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 Hive Service
import 'package:inventory/supabase_db/supabase_client.dart';
import '../../inventory/model/product_model.dart';

class NearExpireProductController extends GetxController with LocalService {
  final String? uid = SupabaseConfig.auth.currentUser?.id;
  RxList<ProductModel> nearExpProductList = <ProductModel>[].obs;
  RxBool isDataloading = false.obs;

  @override
  void onInit() {
    getNearExpiryProducts();
    super.onInit();
  }

  // 🔥 FLOW: Hive Load -> Supabase Fetch -> Hive Sync
  Future<void> getNearExpiryProducts() async {
    if (uid == null) return;

    // 1️⃣ STEP 1: Pehle Hive (Local DB) se data uthao
    final cachedExpiry = LocalService.getCachedExpiryProducts();
    if (cachedExpiry.isNotEmpty) {
      nearExpProductList.value = cachedExpiry;
      print("📦 Near Expiry Data loaded from Hive: ${cachedExpiry.length}");
    }

    // 2️⃣ STEP 2: Supabase se fresh data laao (Fallback)
    // Loading tabhi dikhao agar local mein kuch na ho
    isDataloading.value = nearExpProductList.isEmpty;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final threeMonthsFromNow = now.add(const Duration(days: 90));

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

        final stockList = productData['product_stock'] as List?;
        final sellingPrice =
            (stockList != null && stockList.isNotEmpty)
                ? (stockList[0]['selling_price'] ?? 0.0)
                : 0.0;

        final Map<String, dynamic> productMap = Map<String, dynamic>.from(
          productData,
        );

        productMap['purchase_date'] = batch['purchase_date'];
        productMap['expiry_date'] = batch['expiry_date'];
        productMap['purchase_price'] =
            (batch['purchase_price'] ?? 0).toDouble();
        productMap['quantity'] = (batch['quantity'] ?? 0).toDouble();
        productMap['location'] = batch['location'] ?? 'N/A';
        productMap['stock_type'] = batch['stock_type'] ?? 'packet';
        productMap['selling_price'] = sellingPrice.toDouble();
        productMap['sellingPrice'] = sellingPrice.toDouble();
        productMap['category'] = productData['categories']?['name'] ?? '';
        productMap['animal_type'] =
            productData['animal_categories']?['name'] ?? '';

        final barcodes = productData['product_barcodes'] as List?;
        productMap['barcode'] =
            (barcodes != null && barcodes.isNotEmpty)
                ? barcodes[0]['barcode']
                : '';

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

      // 3️⃣ STEP 3: UI update karo aur Hive mein save karo
      nearExpProductList.value = expiryProducts;
      await LocalService.saveExpiryProducts(expiryProducts);

      print("✅ Hive updated with ${expiryProducts.length} expiry items");
    } catch (e) {
      print("🚨 Expiry Sync Error: $e");
      // Fallback: Agar error aata hai (Airtel error), toh purana data screen par rahega
    } finally {
      isDataloading.value = false;
    }
  }
}
