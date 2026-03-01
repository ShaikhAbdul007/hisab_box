import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/gobal_controller.dart'; // 🔥 GlobalStore
import 'package:inventory/local_db/local_db_service.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/set_format_date.dart';
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
  final globalStore = Get.find<GlobalStore>();

  // --- Saare Existing Variables (No Name Changes) ---
  List<ProductModel> scannedProductDetails = [];
  RxList<DiscountModel> discountList = <DiscountModel>[].obs;
  RxList<DiscountModel> productDiscount = <DiscountModel>[].obs;
  TextEditingController quantity = TextEditingController();
  TextEditingController cashPaidController = TextEditingController(text: '0.0');
  TextEditingController upiPaidController = TextEditingController(text: '0.0');
  TextEditingController cardPaidController = TextEditingController(text: '0.0');
  TextEditingController creditPaidController = TextEditingController(
    text: '0.0',
  );
  TextEditingController roundOffPaidController = TextEditingController(
    text: '0.0',
  );
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
  RxBool isStockLoading = false.obs;
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

  // --- Functions Section ---

  void setUserData() {
    var user = retrieveUserDetail();
    discountPerProduct.value = user.discountPerProduct ?? false;
    shopType.value = user.shoptype ?? '';
  }

  void setProductData() async {
    var dataList = await retrieveCartProductList();
    productList.assignAll(dataList);
    scannedProductDetails = productList;
    perProductDiscount.value = List.generate(productList.length, (i) {
      return TextEditingController(text: productList[i].discount.toString());
    });
    sellingPriceList.value = List.generate(productList.length, (i) {
      return (productList[i].sellingPrice ?? 0).toDouble() *
          (productList[i].quantity ?? 0).toDouble();
    });
    calculateTotalWithDiscount();
  }

  // 🔥 UPDATE QUANTITY (0ms RAM Check)
  Future<void> updateQuantity(bool isIncrement, int index) async {
    isStockOver.value = false;
    var current = productList[index];
    double availableQty = 0.0;

    var ramProduct =
        globalStore.barcodeToProductMap[current.barcode.toString()];

    if (ramProduct != null) {
      availableQty = ramProduct.quantity?.toDouble() ?? 0.0;
    } else {
      availableQty =
          LocalService.getLocalStock(
            current.id ?? '',
            current.isLoosed ?? false,
          ) ??
          0.0;
    }

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

    productList[index] = current;
    saveCartProductList(productList);
    discountCalculateAsPerProduct(index);
    calculateTotalWithDiscount();
    productList.refresh();
  }

  Future<void> saleConfirmed({required RxBool isLoading}) async {
    bool saleConfirm = await confirmSale(
      sellItems: getPrintReadyList(),
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

      double cash = double.tryParse(cashPaidController.text) ?? 0;
      double upi = double.tryParse(upiPaidController.text) ?? 0;
      double card = double.tryParse(cardPaidController.text) ?? 0;
      double credit = double.tryParse(creditPaidController.text) ?? 0;
      final roundOff = double.tryParse(roundOffPaidController.text) ?? 0;
      final finalPayable = double.parse(
        (itemsTotalAmount - roundOff).toStringAsFixed(2),
      );

      int modesCount = [cash, upi, card, credit].where((m) => m > 0).length;
      String currentMode =
          modesCount > 1
              ? 'partial'
              : (cash > 0
                  ? 'cash'
                  : upi > 0
                  ? 'upi'
                  : card > 0
                  ? 'card'
                  : 'credit');

      // 🔥 FIX: Mapping strictly according to your DB Schema [2026-02-28]
      final List<Map<String, dynamic>> saleItemsData =
          sellItems.map((item) {
            return {
              'product_id': item.id, // uuid (NO NULL)
              'stock_type':
                  (item.isLoose == true) ? 'loose' : 'packet', // text (NO NULL)
              'qty': item.quantity?.toInt() ?? 1, // integer (NO NULL)
              'original_price': item.originalPrice ?? 0, // numeric (NO NULL)
              'final_price': item.finalPrice ?? 0, // numeric (NO NULL)
              'location': item.location ?? 'shop', // text (nullable)
              'default_discount_percent': item.originalDiscount ?? 0,
              'applied_discount_percent': item.discount ?? 0,
              'discount_amount':
                  (item.originalPrice ?? 0) - (item.finalPrice ?? 0),
              'user_id': userId,
            };
          }).toList();

      final dynamic response = await SupabaseConfig.client.rpc(
        'process_sale_transaction',
        params: {
          'p_user_id': userId,
          'p_total_amount': finalPayable,
          'p_sale_items': saleItemsData,
          'p_payments': [
            {
              'payment_mode': currentMode,
              'amount': finalPayable,
              'cash_amount': cash,
              'upi_amount': upi,
              'card_amount': card,
              'credit_amount': credit,
              'round_off_amount': roundOff,
              'is_partial': modesCount > 1,
            },
          ],
          'p_stock_updates': stockUpdates,
        },
      );

      final Map<String, dynamic> result = jsonDecode(response.toString());

      // 🟢 RAM SYNC
      globalStore.cashTotal.value += cash;
      globalStore.upiTotal.value += upi;
      globalStore.cardTotal.value += card;
      globalStore.creditTotal.value += credit;

      for (var update in stockUpdates) {
        String pId = update['productId'].toString();
        for (var product in globalStore.barcodeToProductMap.values) {
          if (product.id == pId) product.quantity = update['newQty'];
        }
        int idx = globalStore.allProducts.indexWhere((p) => p.id == pId);
        if (idx != -1) globalStore.allProducts[idx].quantity = update['newQty'];
      }
      globalStore.allProducts.refresh();
      globalStore.barcodeToProductMap.refresh();

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

  Future<Map<String, dynamic>> prepareStockUpdate({
    required String userId,
    required ProductModel product,
  }) async {
    bool isLoose = product.sellType?.toLowerCase() == 'loose';
    String table = isLoose ? 'loose_stocks' : 'product_stock';
    final res =
        await SupabaseConfig.from(table)
            .select('id, quantity')
            .eq('user_id', userId)
            .eq('product_id', product.id ?? '')
            .maybeSingle();
    if (res == null) throw Exception("Product not found");
    double currentQty = (res['quantity'] ?? 0).toDouble();
    double sellQty = (product.quantity ?? 1).toDouble();
    return {
      'table': table,
      'id': res['id'],
      'newQty': currentQty - sellQty,
      'productId': product.id ?? '',
      'isLoose': isLoose,
    };
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
    allEditable.value = remainingAmount.value <= 0;
  }

  bool isAmountValid(String value) {
    if (value.isEmpty) return true;
    double entered = double.tryParse(value) ?? 0;
    isAmountValidCheck.value = entered <= paymentMethodTotalAmount.value;
    return isAmountValidCheck.value;
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
            ? "Partial"
            : (cashPaid > 0
                ? "Cash"
                : upiPaid > 0
                ? "UPI"
                : cardPaid > 0
                ? "Card"
                : "Credit");
    return {
      "type": type,
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
          location: p.location,
          isLoose: p.isLoosed,
        ),
      );
    }
    return sellList;
  }

  void deleteProductFromCart(int index) async {
    productList.removeAt(index);
    if (sellingPriceList.length > index) sellingPriceList.removeAt(index);
    if (perProductDiscount.length > index) perProductDiscount.removeAt(index);
    saveCartProductList(productList);
    calculateTotalWithDiscount();
    productList.refresh();
  }

  void discountCalculateAsPerProduct(int index) {
    sellingPriceList[index] = getSellingPriceAsPerQuantity(index);
  }

  double getSellingPriceAsPerQuantity(int index) {
    var discountV =
        perProductDiscount[index].text.isNotEmpty
            ? double.parse(perProductDiscount[index].text)
            : 0;
    double sPrice =
        (productList[index].sellingPrice ?? 0) *
        (productList[index].quantity ?? 0);
    return sPrice - ((sPrice * discountV) / 100);
  }

  void calculateTotalWithDiscount() {
    finalTotal.value = 0;
    for (var price in sellingPriceList) finalTotal.value += price;
  }

  void calculateDiscount() {
    double originalAmount = getTotalAmount().toDouble();
    double discount = (originalAmount * discountValue.value) / 100;
    discountDifferenceAmount = discount;
    discountPrice.value = originalAmount - discount;
    amount.text = discountPrice.value.toStringAsFixed(2);
  }

  int getTotalAmount() {
    int total = 0;
    for (var product in productList) {
      total += ((product.sellingPrice ?? 0) * (product.quantity ?? 0)).toInt();
    }
    totalAmount.value = total.toDouble();
    return total;
  }

  void clear() {
    cashPaidController.text = '0.0';
    upiPaidController.text = '0.0';
    cardPaidController.text = '0.0';
    creditPaidController.text = '0.0';
    roundOffPaidController.text = '0.0';
    productList.clear();
  }

  Future<void> fetchDiscounts() async {
    var localD = LocalService.getDiscountsFromLocal();
    if (localD.isNotEmpty) discountList.value = localD;
  }
}
