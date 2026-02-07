import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import '../../../helper/helper.dart';
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

    // 1️⃣ Cache check

    // 2️⃣ Supabase fallback (Firebase replaced)
    final data = await fetchRevenueList();
    sellsList.value = data;

    // 3️⃣ Cache save
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

  // ==========================================
  // 🔥 SUPABASE FETCH WITH MODEL MAPPING
  // ==========================================

  Future<List<SellsModel>> fetchRevenueList() async {
    try {
      isRevenueListLoading.value = true; // Replaced Firebase UID
      if (uid == null) return [];

      // Date filtering logic (Start and End of selected dayDate)
      final DateTime selectedDate = DateTime.parse(dayDate.value);
      final String startOfToday =
          DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          ).toIso8601String();
      final String endOfToday =
          DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            23,
            59,
            59,
          ).toIso8601String();

      final response = await SupabaseConfig.from('sales')
          .select('''
          id,
          bill_no,
          total_amount,
          created_at,
          customer_id,
          customers (name, mobile_number),
          sale_items (
            qty,
            final_price,
            original_price,
            discount_amount,
            product_id,
            applied_discount_percent,
            stock_type,
            location,
            products ( name )
          ),
          sale_payments (
            amount,
            payment_mode,
            reference_no
          )
        ''')
          .eq('user_id', uid ?? '')
          .gte('created_at', startOfToday)
          .lte('created_at', endOfToday)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List;

      // Supabase Data ko SellsModel mein map kar rahe hain (UI support ke liye)
      final List<SellsModel> bills =
          data.map((sale) {
            final List<dynamic> dbItems = sale['sale_items'] ?? [];
            final List<dynamic> dbPayments = sale['sale_payments'] ?? [];

            // Map Items
            List<SellItem> mappedItems =
                dbItems.map((item) {
                  return SellItem(
                    name: item['products']?['name'] ?? 'Unknown',
                    quantity: item['qty'] ?? 0,
                    originalPrice: (item['original_price'] ?? 0).toDouble(),
                    finalPrice: (item['final_price'] ?? 0).toDouble(),
                    discount: item['applied_discount_percent'] ?? 0,
                    id: item['product_id'],
                    location: item['location'] ?? 'shop',
                    sellType: item['stock_type'] ?? 'packet',
                  );
                }).toList();

            // Map Payments
            double cash = 0, upi = 0, card = 0, credit = 0;
            for (var p in dbPayments) {
              String mode = p['payment_mode']?.toString().toLowerCase() ?? '';
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

            return SellsModel(
              billNo: sale['bill_no']?.toString() ?? sale['id'].toString(),
              finalAmount: (sale['total_amount'] ?? 0).toDouble(),
              totalAmount: (sale['total_amount'] ?? 0).toDouble(),
              itemsCount: mappedItems.fold(
                0,
                (sum, item) => (sum ?? 0) + (item.quantity ?? 0),
              ),
              soldAt: sale['created_at'].toString().split('T')[0],
              time: sale['created_at'].toString().split('T')[1].split('.')[0],
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
              isDiscountGiven: false,
              discountValue: 0.0,
            );
          }).toList();

      customMessageOrErrorPrint(
        message: '✅ Total Bills Fetched: ${bills.length}',
      );

      return bills;
    } catch (e) {
      showMessage(message: "❌ Error fetching revenue: ${e.toString()}");
      print("🚨 Detail Error: $e");
      return [];
    } finally {
      isRevenueListLoading.value = false;
    }
  }
}
