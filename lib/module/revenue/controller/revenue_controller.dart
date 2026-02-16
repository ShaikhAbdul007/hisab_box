import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import '../model/revenue_model.dart';

class RevenueController extends GetxController with CacheManager {
  final uid = SupabaseConfig.auth.currentUser?.id;
  RxBool isRevenueListLoading = false.obs;
  var sellsList = <SellsModel>[].obs;
  RxDouble sellTotalAmount = 0.0.obs;
  RxString dayDate = ''.obs;

  @override
  void onInit() {
    dayDate.value = setFormateDate();
    dayDate.value = formatDateForDB(dayDate.value);
    setSellList();
    super.onInit();
  }

  void setSellList() async {
    final today = dayDate.value;
    final data = await fetchRevenueList();
    sellsList.value = data;
    saveTodayRevenueCache(date: today, sells: data);
    _calculateTotal();
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var bill in sellsList) {
      total += (bill.finalAmount ?? 0).toDouble();
    }
    sellTotalAmount.value = total;
  }

  Future<List<SellsModel>> fetchRevenueList() async {
    try {
      isRevenueListLoading.value = true;
      if (uid == null) return [];

      final DateTime selectedDate = DateTime.parse(dayDate.value);

      // Timezone safe range
      final String startUtc =
          DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            0,
            0,
            0,
          ).toUtc().toIso8601String();
      final String endUtc =
          DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            23,
            59,
            59,
          ).toUtc().toIso8601String();

      final response = await SupabaseConfig.from('sales')
          .select('''
        id, bill_no, total_amount, created_at,
        customers (name, mobile_number),
        sale_items (
          qty, final_price, original_price, discount_amount, product_id,
          applied_discount_percent, stock_type, location,
          products ( 
            name, 
            weight, 
            flavour, 
            animal_type, 
            category,
            is_loose_category,
            is_flavor_and_weight_not_required,
            categories(name),
            animal_categories(name),
            product_barcodes(barcode)
          )
        ),
        sale_payments (amount, payment_mode, reference_no)
      ''')
          .eq('user_id', uid!)
          .gte('created_at', startUtc)
          .lte('created_at', endUtc)
          .order('created_at', ascending: false);

      final List data = response as List;

      final List<SellsModel> bills =
          data.map((sale) {
            final List dbItems = sale['sale_items'] ?? [];
            final List dbPayments = sale['sale_payments'] ?? [];

            // 🎯 Fix: Detailed Item Mapping
            List<SellItem> mappedItems =
                dbItems.map((item) {
                  final p = item['products'] ?? {};
                  final List? barcodes = p['product_barcodes'] as List?;

                  return SellItem(
                    id: item['product_id'],
                    name: p['name'] ?? 'Unknown',
                    quantity: int.tryParse(item['qty']?.toString() ?? '0') ?? 0,
                    originalPrice: (item['original_price'] ?? 0).toDouble(),
                    finalPrice: (item['final_price'] ?? 0).toDouble(),
                    discount:
                        int.tryParse(
                          item['applied_discount_percent']?.toString() ?? '0',
                        ) ??
                        0,

                    // ✨ Missing Fields Fixed Here:
                    barcode:
                        (barcodes != null && barcodes.isNotEmpty)
                            ? barcodes[0]['barcode']
                            : '',
                    category: p['categories']?['name'] ?? p['category'] ?? '',
                    animalType:
                        p['animal_categories']?['name'] ??
                        p['animal_type'] ??
                        '',
                    weight: p['weight']?.toString() ?? '',
                    flavours: p['flavour']?.toString() ?? '',
                    isLooseCategory: p['is_loose_category'] ?? false,
                    isFlavorAndWeightNotRequired:
                        p['is_flavor_and_weight_not_required'] ?? false,
                    location: item['location'] ?? 'shop',
                    sellType: item['stock_type'] ?? 'packet',
                    isLoose: item['stock_type'] == 'loose',
                  );
                }).toList();

            // Payment Mapping (Same as before)
            double cash = 0, upi = 0, card = 0, credit = 0;
            for (var p in dbPayments) {
              String mode =
                  p['payment_mode']?.toString().toLowerCase().trim() ?? '';
              double amt = (p['amount'] ?? 0).toDouble();
              if (mode == 'cash') {
                cash += amt;
              } else if (mode == 'upi') {
                upi += amt;
              } else if (mode == 'card') {
                card += amt;
              } else if (mode == 'credit') {
                credit += amt;
              }
            }

            DateTime createdTime =
                DateTime.parse(sale['created_at'].toString()).toLocal();

            return SellsModel(
              billNo: sale['bill_no'] ?? 0,
              finalAmount: (sale['total_amount'] ?? 0).toDouble(),
              totalAmount: (sale['total_amount'] ?? 0).toDouble(),
              itemsCount: mappedItems.fold(
                0,
                (sum, item) => (sum ?? 0) + (item.quantity ?? 0),
              ),
              soldAt: createdTime.toString().split(' ')[0],
              time: createdTime.toString().split(' ')[1].split('.')[0],
              items: mappedItems,
              payment: PaymentModel(
                cash: cash,
                upi: upi,
                card: card,
                credit: credit,
                totalAmount: (sale['total_amount'] ?? 0).toDouble(),
                isRoundOff: false,
                roundOffAmount: 0.0,
                type:
                    dbPayments.isNotEmpty
                        ? dbPayments.first['payment_mode']
                        : 'Cash',
              ),
            );
          }).toList();

      return bills;
    } catch (e) {
      print("🚨 Detail Error: $e");
      return [];
    } finally {
      isRevenueListLoading.value = false;
    }
  }
}
