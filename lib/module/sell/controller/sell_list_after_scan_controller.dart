import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Mixin
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/sell/model/sell_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import '../../../routes/route_name.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/sell/model/print_model.dart';
import '../../../routes/routes.dart';
import '../../discount/model/discount_model.dart';
import '../../../helper/helper.dart';
import '../../loose_category/model/loose_category_model.dart';

class SellListAfterScanController extends GetxController
    with CacheManager, LocalService {
  final userId = SupabaseConfig.auth.currentUser?.id;
  List<ProductModel> scannedProductDetails = [];
  RxList<DiscountModel> discountList = <DiscountModel>[].obs;
  RxList<DiscountModel> productDiscount = <DiscountModel>[].obs;
  TextEditingController quantity = TextEditingController();
  TextEditingController cashPaidController = TextEditingController();
  TextEditingController upiPaidController = TextEditingController();
  TextEditingController cardPaidController = TextEditingController();
  TextEditingController creditPaidController = TextEditingController();
  TextEditingController roundOffPaidController = TextEditingController();
  TextEditingController name = TextEditingController();
  RxList<TextEditingController> perProductDiscount =
      <TextEditingController>[].obs;
  TextEditingController amount = TextEditingController();
  RxList<LooseCategoryModel> looseCategoryModelList =
      <LooseCategoryModel>[].obs;
  Rx<ReceiptController?> receiptController = Rx<ReceiptController?>(null);
  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxDouble totalAmount = 0.0.obs;
  RxDouble newSellingPrice = 0.0.obs;
  RxInt discountValue = 0.obs;
  RxInt billNo = 0.obs;
  RxDouble updateSellingPrice = 0.0.obs;
  RxBool isCardLoading = false.obs;
  RxBool isCashLoading = false.obs;
  RxBool isPartailLoading = false.obs;
  RxBool isOnlineLoading = false.obs;
  RxBool isAmountValidCheck = false.obs;
  RxBool isStockOver = false.obs;
  RxBool isStockLoading = false.obs; // Added for loading state
  RxBool isDiscountGiven = false.obs;
  RxBool isPrintingLoading = false.obs;
  RxBool isSaveLoading = false.obs;
  double discountDifferenceAmount = 0.0;
  RxDouble discountPrice = 0.0.obs;
  RxDouble paymentMethodTotalAmount = 0.0.obs;
  RxDouble remainingAmount = 0.0.obs;
  RxDouble upiPaid = 0.0.obs;
  RxDouble cardPaid = 0.0.obs;
  RxDouble creditPaid = 0.0.obs;
  RxDouble cashPaid = 0.0.obs;
  RxBool allEditable = false.obs;
  var data = Get.arguments;
  String? id;
  RxBool discountPerProduct = false.obs;
  RxString shopType = ''.obs;
  var finalTotal = 0.0.obs;
  var sellingPriceList = <double>[].obs;
  List<SellItem> sellList = [];
  var printInvoice = Rx<PrintInvoiceModel?>(null);

  @override
  void onInit() {
    setUserData();
    fetchDiscounts();
    setProductData();
    super.onInit();
  }

  void setUserData() {
    var user = retrieveUserDetail();
    discountPerProduct.value = user.discountPerProduct ?? false;
    shopType.value = user.shoptype ?? '';
  }

  void setProductData() async {
    var dataList = await retrieveCartProductList();
    productList.value = dataList;
    scannedProductDetails = productList;
    perProductDiscount.value = List.generate(productList.length, (i) {
      return TextEditingController(text: dataList[i].discount.toString());
    });
    sellingPriceList.value = List.generate(productList.length, (i) {
      return productList[i].sellingPrice!.toDouble() *
          productList[i].quantity!.toDouble();
    });
    calculateTotalWithDiscount();
  }

  void discountCalculateAsPerProduct(int index) {
    double price = getSellingPriceAsPerQuantity(index);
    sellingPriceList[index] = price;
  }

  double getSellingPriceAsPerQuantity(int index) {
    double finalTotalAmount = 0;
    var discountValue =
        perProductDiscount[index].text.isNotEmpty
            ? double.parse(perProductDiscount[index].text)
            : 0;
    double sellingPrice =
        (productList[index].sellingPrice!) *
        (productList[index].quantity!.toInt());
    double discountAmount = (sellingPrice * discountValue) / 100;
    finalTotalAmount = sellingPrice - discountAmount;
    return finalTotalAmount;
  }

  void openPaymentDialog(double amount) {
    paymentMethodTotalAmount.value = amount;
    remainingAmount.value = amount;
    allEditable.value = false;
  }

  void updateRemainingAmount() {
    double paid =
        (double.tryParse(cashPaidController.text) ?? 0) +
        (double.tryParse(upiPaidController.text) ?? 0) +
        (double.tryParse(cardPaidController.text) ?? 0) +
        (double.tryParse(creditPaidController.text) ?? 0) +
        (double.tryParse(roundOffPaidController.text) ?? 0);

    remainingAmount.value = double.parse(
      (paymentMethodTotalAmount.value - paid).toStringAsFixed(2),
    );
    if (remainingAmount.value > 0) {
      allEditable.value = false;
    } else {
      allEditable.value = true;
    }
  }

  bool isAmountValid(String value) {
    bool valid;
    if (value.isEmpty) return true;

    double entered = double.tryParse(value) ?? 0;
    double total = paymentMethodTotalAmount.value;

    if (entered > total) {
      isAmountValidCheck.value = false;
      valid = false;
    } else {
      isAmountValidCheck.value = true;
      valid = true;
    }
    return valid;
  }

  // 🔥 DELETE PRODUCT FROM CART (With Hive Sync)
  void deleteProductFromCart(int index) async {
    try {
      // 1. Local List se remove karo
      productList.removeAt(index);

      // 2. Selling Price aur Discount controllers ki lists bhi update karo (Taaki index out of bounds na ho)
      if (sellingPriceList.length > index) sellingPriceList.removeAt(index);
      if (perProductDiscount.length > index) perProductDiscount.removeAt(index);

      // 3. Hive (Cache Manager) mein updated list save karo
      // Ye aapka existing 'saveCartProductList' function use karega
      saveCartProductList(productList);

      // 4. Totals recalculate karo
      calculateTotalWithDiscount();

      // 5. UI Refresh
      productList.refresh();

      showMessage(message: "Product removed from cart");
    } catch (e) {
      print("🚨 Delete Error: $e");
      showMessage(message: "Could not remove product");
    }
  }

  void calculateDiscount() {
    double originalAmount = getTotalAmount().toDouble();
    double discount = (originalAmount * discountValue.value) / 100;
    discountDifferenceAmount = discount;
    double discountedAmount = originalAmount - discount;
    discountPrice.value = discountedAmount;
    amount.text = discountedAmount.toStringAsFixed(2);
  }

  void clear() {
    cashPaidController.text = '0.0';
    upiPaidController.text = '0.0';
    cardPaidController.text = '0.0';
    creditPaidController.text = '0.0';
    roundOffPaidController.text = '0.0';
  }

  int getTotalAmount() {
    int total = 0;
    for (var product in productList) {
      int price = (product.sellingPrice ?? 0).toInt();
      int qty = (product.quantity ?? 0).toInt();
      total += price * qty;
    }
    totalAmount.value = total.toDouble();
    return total;
  }

  void calculateTotalWithDiscount() {
    finalTotal.value = 0; // reset first
    if (sellingPriceList.isNotEmpty) {
      for (int i = 0; i < sellingPriceList.length; i++) {
        finalTotal.value += sellingPriceList[i];
      }
    } else {
      finalTotal.value = getTotalAmount().toDouble();
    }
  }

  // 🔥 UPDATE QUANTITY WITH HIVE FALLBACK & SYNC
  Future<void> updateQuantity(bool isIncrement, int index) async {
    isStockOver.value = false;
    var current = productList[index];
    double availableQty = 0.0;
    bool isLoose = current.sellType?.toLowerCase() == 'loose';

    try {
      // 1. FALLBACK: Pehle Hive se stock check karo (Multiple Barcode logic handle ho jayegi)
      var localStock = LocalService.getLocalStock(current.id ?? '', isLoose);

      if (localStock != null) {
        availableQty = localStock;
      } else {
        // 2. Agar Hive mein nahi hai, toh Supabase se fetch karo
        final table = isLoose ? 'loose_stocks' : 'product_stock';
        final res =
            await SupabaseConfig.from(table)
                .select('quantity')
                .eq('product_id', current.id ?? '')
                .maybeSingle();

        availableQty =
            double.tryParse(res?['quantity']?.toString() ?? '0.0') ?? 0.0;

        // 3. Hive mein save kar do for next time
        await LocalService.updateLocalStock(
          current.id ?? '',
          availableQty,
          isLoose,
        );
      }

      // Logic for Increment/Decrement
      if (isIncrement) {
        if ((current.quantity ?? 0) < availableQty) {
          current.quantity = (current.quantity ?? 0) + 1;
        } else {
          isStockOver.value = true;
          showSnackBar(error: "Out of Stock! Only $availableQty available.");
          return;
        }
      } else {
        if ((current.quantity ?? 1) > 1) {
          current.quantity = (current.quantity ?? 1) - 1;
        }
      }

      // UI Update and Hive Cart Update
      productList[index] = current;
      saveCartProductList(productList);

      discountCalculateAsPerProduct(index);
      calculateTotalWithDiscount();
      productList.refresh();
    } catch (e) {
      print("🚨 Stock Error: $e");
    }
  }

  Future<void> saleConfirmed({required RxBool isLoading}) async {
    bool saleConfirm = await confirmSale(
      sellItems: sellList,
      isLoading: isLoading,
    );
    if (saleConfirm == true) {
      removeCartProductList();
      AppRoutes.navigateRoutes(
        routeName: AppRouteName.orderView,
        data: printInvoice.value,
      );
    } else {
      Get.back();
      removeCartProductList();
      showMessage(message: somethingWentMessage);
    }
  }

  // 🔥 FETCH DISCOUNTS WITH HIVE FALLBACK
  Future<void> fetchDiscounts() async {
    if (userId == null) return;

    // 1. Pehle Hive se uthao
    var localDiscounts = LocalService.getDiscountsFromLocal();
    if (localDiscounts.isNotEmpty) {
      discountList.value = localDiscounts;
    }

    try {
      // 2. Background mein Supabase se fetch karo sync rakhne ke liye
      final response = await SupabaseConfig.from(
        'discounts',
      ).select('*').eq('user_id', userId!);

      var freshDiscounts =
          response.map((data) => DiscountModel.fromJson(data)).toList();
      discountList.value = freshDiscounts;

      // 3. Hive Update
      await LocalService.saveDiscountsToLocal(freshDiscounts);
    } catch (e) {
      customMessageOrErrorPrint(message: "Discount Error: $e");
    }
  }

  Future<Map<String, dynamic>> prepareStockUpdate({
    required String userId,
    required ProductModel product,
  }) async {
    bool isLoose = product.sellType?.toLowerCase() == 'loose';
    String table = isLoose ? 'loose_stocks' : 'product_stock';

    final response =
        await SupabaseConfig.from(table)
            .select('id, quantity')
            .eq('user_id', userId)
            .eq('product_id', product.id ?? '')
            .maybeSingle();

    if (response == null) throw Exception("Product not found");

    double currentQty = (response['quantity'] ?? 0).toDouble();
    double sellQty = (product.quantity ?? 1).toDouble();
    double newQty = currentQty - sellQty;

    return {
      'table': table,
      'id': response['id'],
      'newQty': newQty,
      'productId': product.id ?? '',
      'isLoose': isLoose,
    };
  }

  // 🔥 CONFIRM SALE WITH HIVE SYNC
  Future<bool> confirmSale({
    required List<SellItem> sellItems,
    required RxBool isLoading,
  }) async {
    isLoading.value = true;
    if (userId == null) return false;

    try {
      List<Map<String, dynamic>> stockUpdates = [];
      double itemsTotalAmount = 0;

      for (final product in scannedProductDetails) {
        final update = await prepareStockUpdate(
          userId: userId!,
          product: product,
        );
        stockUpdates.add(update);
      }

      for (var item in sellItems) {
        itemsTotalAmount += item.finalPrice ?? 0;
      }

      final roundOff = double.tryParse(roundOffPaidController.text) ?? 0;
      final finalPayable = double.parse(
        (itemsTotalAmount - roundOff).toStringAsFixed(2),
      );

      double cash = double.tryParse(cashPaidController.text) ?? 0;
      double upi = double.tryParse(upiPaidController.text) ?? 0;
      double card = double.tryParse(cardPaidController.text) ?? 0;
      double credit = double.tryParse(creditPaidController.text) ?? 0;

      int modesCount = [cash, upi, card, credit].where((m) => m > 0).length;

      List<Map<String, dynamic>> paymentRecords = [
        {
          'payment_mode':
              modesCount > 1
                  ? 'partial'
                  : (cash > 0
                      ? 'cash'
                      : upi > 0
                      ? 'upi'
                      : card > 0
                      ? 'card'
                      : 'credit'),
          'amount': finalPayable,
          'cash_amount': cash,
          'upi_amount': upi,
          'card_amount': card,
          'credit_amount': credit,
          'round_off_amount': roundOff,
          'is_partial': modesCount > 1,
        },
      ];

      final saleItemsData =
          sellItems
              .map(
                (item) => {
                  'product_id': item.id,
                  'qty': item.quantity,
                  'original_price': item.originalPrice ?? item.finalPrice ?? 0,
                  'discount_amount':
                      (item.originalPrice ?? 0) - (item.finalPrice ?? 0),
                  'final_price': item.finalPrice ?? 0,
                  'location': item.location ?? 'shop',
                  'stock_type': item.isLoose == true ? 'loose' : 'packet',
                  'applied_discount_percent': item.discount ?? 0,
                  'default_discount_percent': item.originalDiscount ?? 0,
                },
              )
              .toList();

      // EXECUTE TRANSACTION
      final dynamic response = await SupabaseConfig.client.rpc(
        'process_sale_transaction',
        params: {
          'p_user_id': userId,
          'p_total_amount': finalPayable,
          'p_sale_items': saleItemsData,
          'p_payments': paymentRecords,
          'p_stock_updates': stockUpdates,
        },
      );

      final Map<String, dynamic> result = jsonDecode(response.toString());

      // =========================================================================
      // 🟢 START: NEW LOCAL SYNC LOGIC (Dashboard & Report Updates)
      // =========================================================================

      // 1. [NEW] Aaj ki date nikaalo Hive key ke liye
      final String todayDate = setFormateDate('yyyy-MM-dd');

      // 2. [NEW] Nayi sale ka data SaleModel ke format mein ready karo (Recent Activity ke liye)
      final newSaleForLocal = {
        'billNo': result['bill_no'].toString(),
        'soldAt': setFormateDate(),
        'time': setFormateDate('hh:mm:ss a'),
        'amountAfterDiscount': finalPayable,
        'amount': itemsTotalAmount,
        'barcode': sellItems.isNotEmpty ? sellItems.first.barcode : '',
        'name':
            sellItems.length > 1
                ? "Multiple Items"
                : (sellItems.isNotEmpty ? sellItems.first.name : "Sale"),
        'quantity': sellItems.length,
        'category': '',
        'animalType': '',
        'flavor': '',
        'weight': '',
        'discountValue': 0.0,
        'sellingPrice': finalPayable,
      };

      // 3. [NEW] Today's Sales list update karo (Home Screen ki bottom list)
      List<SaleModel> currentTodaySales = LocalService.getTodaySales(todayDate);
      currentTodaySales.insert(0, SaleModel.fromMap(newSaleForLocal));
      await LocalService.saveTodaySales(todayDate, currentTodaySales);

      // 4. [NEW] Dashboard Stats update karo (Home & Overview cards: Cash, UPI, Credit)
      Map<String, dynamic> stats = LocalService.getDailyReportStats();
      stats['total_sales'] =
          (double.tryParse(stats['total_sales']?.toString() ?? '0.0') ?? 0.0) +
          finalPayable;
      stats['cash_total'] =
          (double.tryParse(stats['cash_total']?.toString() ?? '0.0') ?? 0.0) +
          cash;
      stats['upi_total'] =
          (double.tryParse(stats['upi_total']?.toString() ?? '0.0') ?? 0.0) +
          upi;
      stats['card_total'] =
          (double.tryParse(stats['card_total']?.toString() ?? '0.0') ?? 0.0) +
          card;
      stats['credit_total'] =
          (double.tryParse(stats['credit_total']?.toString() ?? '0.0') ?? 0.0) +
          credit;
      await LocalService.saveDailyReportStats(stats);

      // 5. [NEW] Stock & Out of Stock update (Dashboard card "Out of Stock")
      List<ProductModel> outOfStockList =
          LocalService.getCachedOutOfStockProducts();
      for (var update in stockUpdates) {
        await LocalService.updateStock(
          update['productId'],
          update['newQty'],
        ); // Local stock update

        if (update['newQty'] <= 0) {
          // Agar stock 0 hua, toh out of stock list mein add karo
          var product = productList.firstWhere(
            (p) => p.id == update['productId'],
          );
          if (!outOfStockList.any((p) => p.id == product.id)) {
            outOfStockList.add(product);
          }
        }
      }
      await LocalService.saveOutOfStockProducts(outOfStockList);

      // =========================================================================
      // 🔴 END: NEW LOCAL SYNC LOGIC
      // =========================================================================

      final saleData = {
        'billNo': result['bill_no'],
        'soldAt': setFormateDate(),
        'time': setFormateDate('hh:mm:ss a'),
        'totalAmount': finalPayable,
        'payment': buildPaymentMap(
          totalAmount: itemsTotalAmount,
          cashPaid: cash,
          upiPaid: upi,
          cardPaid: card,
          creditPaid: credit,
          roundOffPaid: roundOff,
        ),
        'items': sellItems.map((e) => e.toJson()).toList(),
      };

      printInvoice.value = PrintInvoiceModel.fromJson(saleData);
      scannedProductDetails.clear();
      clear();

      return true;
    } catch (e) {
      print("🚨 Sale Failed: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> buildPaymentMap({
    required num totalAmount,
    required num cashPaid,
    required num upiPaid,
    required num cardPaid,
    required num creditPaid,
    required num roundOffPaid,
  }) {
    int count =
        [cashPaid, upiPaid, cardPaid, creditPaid].where((m) => m > 0).length;
    String type =
        count > 1
            ? "partial"
            : (cashPaid > 0
                ? "cash"
                : upiPaid > 0
                ? "upi"
                : cardPaid > 0
                ? "card"
                : creditPaid > 0
                ? "credit"
                : "unknown");

    return {
      "type": type.capitalizeFirst,
      "totalAmount": totalAmount,
      "cash": cashPaid,
      "upi": upiPaid,
      "card": cardPaid,
      "credit": creditPaid,
      "roundOffAmount": roundOffPaid,
      "isRoundOff": roundOffPaid != 0,
    };
  }

  List<SellItem> getPrintReadyList() {
    sellList.clear();
    for (int i = 0; i < productList.length; i++) {
      var p = productList[i];
      sellList.add(
        SellItem(
          name: p.name,
          quantity: p.quantity?.toInt() ?? 0,
          originalPrice: p.sellingPrice,
          originalDiscount: p.discount,
          discount: int.tryParse(perProductDiscount[i].text) ?? 0,
          finalPrice: sellingPriceList[i],
          category: p.category,
          barcode: p.barcode.toString(),
          id: p.id,
          purchasePrice: p.purchasePrice,
          weight: p.weight,
          flavours: p.flavor,
          animalType: p.animalType,
          color: p.color,
          isLoose: p.isLoosed,
          isFlavorAndWeightNotRequired: p.isFlavorAndWeightNotRequired,
          exprieDate: p.expireDate,
          location: p.location,
        ),
      );
    }
    return sellList;
  }
}
