import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/discount/model/discount_model.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';
import 'package:inventory/module/loose_category/model/loose_category_model.dart';
import 'package:inventory/module/sell/model/print_model.dart';
import 'package:inventory/module/sell/repo/sell_repo.dart';
import '../../../routes/route_name.dart';
import '../../../routes/routes.dart';

class SellListAfterScanController extends GetxController with CacheManager {
  SellRepo sellRepo = SellRepo();
  // ── Cart & product state ──────────────────────────────────────────────────
  RxList<InventoryItem> productList = <InventoryItem>[].obs;
  List<InventoryItem> scannedProductDetails = [];
  RxList<TextEditingController> perProductDiscount =
      <TextEditingController>[].obs;
  var sellingPriceList = <double>[].obs;

  // ── Discount ──────────────────────────────────────────────────────────────
  RxList<DiscountModel> discountList = <DiscountModel>[].obs;
  RxList<DiscountModel> productDiscount = <DiscountModel>[].obs;
  RxInt discountValue = 0.obs;
  RxBool isDiscountGiven = false.obs;
  RxBool discountPerProduct = false.obs;
  double discountDifferenceAmount = 0.0;
  RxDouble discountPrice = 0.0.obs;

  // ── Totals ────────────────────────────────────────────────────────────────
  RxDouble totalAmount = 0.0.obs;
  var finalTotal = 0.0.obs;
  TextEditingController amount = TextEditingController();

  // ── Payment inputs ────────────────────────────────────────────────────────
  TextEditingController cashPaidController = TextEditingController(text: '0.0');
  TextEditingController upiPaidController = TextEditingController(text: '0.0');
  TextEditingController cardPaidController = TextEditingController(text: '0.0');
  TextEditingController creditPaidController = TextEditingController(
    text: '0.0',
  );
  TextEditingController roundOffPaidController = TextEditingController(
    text: '0.0',
  );
  RxDouble paymentMethodTotalAmount = 0.0.obs;
  RxDouble remainingAmount = 0.0.obs;
  RxDouble upiPaid = 0.0.obs;
  RxDouble cardPaid = 0.0.obs;
  RxDouble creditPaid = 0.0.obs;
  RxDouble cashPaid = 0.0.obs;
  RxBool allEditable = false.obs;
  RxBool isAmountValidCheck = false.obs;

  // ── Loading flags ─────────────────────────────────────────────────────────
  RxBool isCardLoading = false.obs;
  RxBool isCashLoading = false.obs;
  RxBool isPartailLoading = false.obs;
  RxBool isOnlineLoading = false.obs;
  RxBool isStockOver = false.obs;
  RxBool isStockLoading = false.obs;
  RxBool isPrintingLoading = false.obs;
  RxBool isSaveLoading = false.obs;

  // ── Misc ──────────────────────────────────────────────────────────────────
  TextEditingController quantity = TextEditingController();
  TextEditingController name = TextEditingController();
  RxList<LooseCategoryModel> looseCategoryModelList =
      <LooseCategoryModel>[].obs;
  Rx<ReceiptController?> receiptController = Rx<ReceiptController?>(null);
  RxInt billNo = 0.obs;
  RxDouble newSellingPrice = 0.0.obs;
  RxDouble updateSellingPrice = 0.0.obs;
  RxString shopType = ''.obs;
  var data = Get.arguments;
  String? id;
  //List<SellItem> sellList = [];
  // var printInvoice = Rx<PrintInvoiceModel?>(null);

  @override
  void onInit() {
    fetchDiscounts();
    setProductData();
    super.onInit();
  }

  // ── Cart setup ────────────────────────────────────────────────────────────

  void setProductData() async {
    final dataList = await retrieveCartProductList();
    productList.assignAll(dataList);
    scannedProductDetails = List.from(dataList);

    perProductDiscount.value = List.generate(productList.length, (i) {
      return TextEditingController(
        text: productList[i].discount?.toString() ?? '0',
      );
    });

    sellingPriceList.value = List.generate(
      productList.length,
      (i) => _itemSellingPrice(i),
    );

    calculateTotalWithDiscount();
  }

  // ── Quantity ──────────────────────────────────────────────────────────────

  Future<void> updateQuantity(bool isIncrement, int index) async {
    isStockOver.value = false;
    final current = productList[index];
    final currentQty = int.tryParse(current.quantity ?? '0') ?? 0;

    final double availableQty = 0.0;

    if (isIncrement) {
      if (currentQty < availableQty) {
        current.quantity = (currentQty + 1).toString();
      } else {
        isStockOver.value = true;
        showSnackBar(error: "Out of Stock! Only $availableQty available.");
        return;
      }
    } else {
      if (currentQty > 1) {
        current.quantity = (currentQty - 1).toString();
      }
    }

    productList[index] = current;
    saveCartProductList(productList);
    discountCalculateAsPerProduct(index);
    calculateTotalWithDiscount();
    productList.refresh();
  }

  // ── Sale confirmation ─────────────────────────────────────────────────────

  Future<void> saleConfirmed({required RxBool isLoading}) async {
    isLoading.value = true;

    // Build items list
    final List<Map<String, dynamic>> items = [];
    for (int i = 0; i < productList.length; i++) {
      final item = productList[i];
      final double qty = double.tryParse(item.quantity ?? '1') ?? 1;
      final double originalPrice =
          double.tryParse(item.sellingPrice ?? '0') ?? 0;
      final int originalDiscount = item.discount ?? 0;
      final double discountGivenPct =
          double.tryParse(perProductDiscount[i].text) ?? 0;

      // price after item-level discount (per-product discount given in dialog)
      final double discountedPrice = double.parse(
        (originalPrice - (originalPrice * discountGivenPct / 100))
            .toStringAsFixed(2),
      );

      items.add({
        'barcode': item.barcode ?? item.barcodes ?? '',
        'qty': qty.toInt(),
        'original_price': originalPrice,
        'original_discount': originalDiscount,
        'discounted_price': discountedPrice,
        'discount_given': discountGivenPct,
        'stock_type': item.stockType ?? '',
        'location': item.location ?? '',
      });
    }

    // Build payments list (only modes with amount > 0)
    final List<Map<String, dynamic>> payments = [];
    final Map<String, double> modes = {
      'cash': double.tryParse(cashPaidController.text) ?? 0,
      'upi': double.tryParse(upiPaidController.text) ?? 0,
      'card': double.tryParse(cardPaidController.text) ?? 0,
      'credit': double.tryParse(creditPaidController.text) ?? 0,
      'round_off': double.tryParse(roundOffPaidController.text) ?? 0,
    };
    modes.forEach((mode, amount) {
      if (amount > 0) {
        payments.add({'mode': mode, 'amount': amount});
      }
    });

    final body = {'items': items, 'payments': payments};

    print('the sale body is $body');
    final response = await sellRepo.postSellData(body: body);
    isLoading.value = false;

    if (response.success == true) {
      removeCartProductList();
      AppRoutes.navigateRoutes(
        routeName: AppRouteName.orderView,
        data: response.data?.invoiceNo,
      );
    } else {
      Get.back();
      removeCartProductList();
      showSnackBar(error: somethingWentMessage);
    }
  }

  void openPaymentDialog(double amt) {
    paymentMethodTotalAmount.value = amt;
    remainingAmount.value = amt;
    allEditable.value = false;
  }

  void updateRemainingAmount() {
    final double paid =
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
    final double entered = double.tryParse(value) ?? 0;
    isAmountValidCheck.value = entered <= paymentMethodTotalAmount.value;
    return isAmountValidCheck.value;
  }

  // ── Cart operations ───────────────────────────────────────────────────────

  void deleteProductFromCart(int index) {
    productList.removeAt(index);
    if (sellingPriceList.length > index) sellingPriceList.removeAt(index);
    if (perProductDiscount.length > index) perProductDiscount.removeAt(index);
    saveCartProductList(productList);
    calculateTotalWithDiscount();
    productList.refresh();
  }

  // ── Discount calculations ─────────────────────────────────────────────────

  void discountCalculateAsPerProduct(int index) {
    sellingPriceList[index] = _itemSellingPrice(index);
  }

  double _itemSellingPrice(int index) {
    final double discountV =
        double.tryParse(perProductDiscount[index].text) ?? 0;
    final double qty = double.tryParse(productList[index].quantity ?? '1') ?? 1;
    final double price =
        double.tryParse(productList[index].sellingPrice ?? '0') ?? 0;
    final double sPrice = price * qty;
    return sPrice - ((sPrice * discountV) / 100);
  }

  void calculateTotalWithDiscount() {
    finalTotal.value = sellingPriceList.fold(0.0, (sum, p) => sum + p);
  }

  void calculateDiscount() {
    final double originalAmount = getTotalAmount().toDouble();
    final double discount = (originalAmount * discountValue.value) / 100;
    discountDifferenceAmount = discount;
    discountPrice.value = originalAmount - discount;
    amount.text = discountPrice.value.toStringAsFixed(2);
  }

  int getTotalAmount() {
    int total = 0;
    for (final product in productList) {
      final double qty = double.tryParse(product.quantity ?? '0') ?? 0;
      final double price = double.tryParse(product.sellingPrice ?? '0') ?? 0;
      total += (price * qty).toInt();
    }
    totalAmount.value = total.toDouble();
    return total;
  }

  // ── Discounts fetch ───────────────────────────────────────────────────────

  Future<void> fetchDiscounts() async {
    // final localD = LocalService.getDiscountsFromLocal();
    // if (localD.isNotEmpty) discountList.value = localD;
  }

  // ── Clear helpers ─────────────────────────────────────────────────────────

  void clearPaymentInputs() {
    cashPaidController.text = '0.0';
    upiPaidController.text = '0.0';
    cardPaidController.text = '0.0';
    creditPaidController.text = '0.0';
    roundOffPaidController.text = '0.0';
    paymentMethodTotalAmount.value = 0.0;
    remainingAmount.value = 0.0;
    allEditable.value = false;
    isAmountValidCheck.value = true;
  }

  void clearSellSessionData() {
    productList.clear();
    sellingPriceList.clear();
    perProductDiscount.clear();
    finalTotal.value = 0.0;
    totalAmount.value = 0.0;
    discountPrice.value = 0.0;
    discountDifferenceAmount = 0.0;
  }
}
