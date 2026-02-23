import 'package:get/get.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 Aapki Local DB file
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import '../model/revenue_model.dart';

class RevenueController extends GetxController with LocalService {
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

  // 🔥 Flow: Pehle Hive se data dikhao, fir background mein Supabase se sync karo
  void setSellList() async {
    final today = dayDate.value;

    // 1. Hive se purana data uthao (Immediate Display)
    final cachedData = LocalService.getRevenueFromLocal(today);
    if (cachedData.isNotEmpty) {
      sellsList.value = cachedData;
      _calculateTotal();
    }

    // 2. Supabase se fresh data lao
    final freshData = await fetchRevenueList();
    if (freshData.isNotEmpty) {
      sellsList.value = freshData;
      _calculateTotal();
      // 3. Naye data ko Hive mein save/update karo
      await LocalService.saveRevenueToLocal(today, freshData);
    }
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

      // Timezone safe range for exact day
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
            name, weight, flavour, animal_type, category,
            is_loose_category, is_flavor_and_weight_not_required,
            categories(name),
            animal_categories(name),
            product_barcodes(barcode)
          )
        ),
        sale_payments (
          amount, payment_mode, reference_no, round_off_amount,
          cash_amount, upi_amount, card_amount, credit_amount
        )
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

            // Detailed Item Mapping
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

            // 🎯 Payment Mapping with Schema Columns
            double cash = 0, upi = 0, card = 0, credit = 0, roundOffAmt = 0;
            for (var p in dbPayments) {
              cash += (p['cash_amount'] ?? 0).toDouble();
              upi += (p['upi_amount'] ?? 0).toDouble();
              card += (p['card_amount'] ?? 0).toDouble();
              credit += (p['credit_amount'] ?? 0).toDouble();
              roundOffAmt += (p['round_off_amount'] ?? 0.0).toDouble();
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
                isRoundOff: roundOffAmt != 0,
                roundOffAmount: roundOffAmt,
                type:
                    dbPayments.isNotEmpty
                        ? dbPayments.first['payment_mode']
                        : 'Cash',
              ),
            );
          }).toList();

      return bills;
    } catch (e) {
      print("🚨 Revenue Fetch Error: $e");
      return [];
    } finally {
      isRevenueListLoading.value = false;
    }
  }
}
