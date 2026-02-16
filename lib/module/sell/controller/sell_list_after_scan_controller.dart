import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
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

class SellListAfterScanController extends GetxController with CacheManager {
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
      return TextEditingController(text: '0');
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

    // Initially only first field editable
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
      // invalid
    } else {
      isAmountValidCheck.value = true;
      valid = true;
    }
    return valid;
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
    if (sellingPriceList.length.isGreaterThan(0)) {
      for (int i = 0; i < sellingPriceList.length; i++) {
        finalTotal.value += sellingPriceList[i];
      }
    } else {
      finalTotal.value = getTotalAmount().toDouble();
    }
  }

  Future<void> updateQuantity(bool isIncrement, int index) async {
    isStockOver.value = false;
    var current = productList[index];

    // 🎯 DEBUG: Console mein check karo ID aa rahi hai ya nahi
    print("🔍 Checking Live Stock for ID: ${current.id}");

    double availableQty = 0.0;

    try {
      if (current.sellType?.toLowerCase() == 'loose') {
        // --- DIRECT SUPABASE CHECK (Loose) ---
        final looseRes =
            await SupabaseConfig.from('loose_stocks')
                .select('quantity')
                .eq('product_id', current.id ?? '')
                .maybeSingle();

        if (looseRes == null) {
          showSnackBar(error: "Loose product stock not found in Database");
          return;
        }
        availableQty =
            double.tryParse(looseRes['quantity']?.toString() ?? '0.0') ?? 0.0;
      } else {
        // --- DIRECT SUPABASE CHECK (Packet) ---
        final stockRes =
            await SupabaseConfig.from('product_stock')
                .select('quantity')
                .eq('product_id', current.id ?? "")
                .eq('stock_type', 'packet')
                .eq('location', 'shop')
                .maybeSingle();

        if (stockRes == null) {
          showSnackBar(error: "Packet stock not found in Database");
          return;
        }
        availableQty =
            double.tryParse(stockRes['quantity']?.toString() ?? '0.0') ?? 0.0;
      }

      // 2. Increment/Decrement Logic
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

      // 3. UI Update and Save Cart
      productList[index] = current;
      saveCartProductList(productList); // Cart save karna zaroori hai

      discountCalculateAsPerProduct(index);
      calculateTotalWithDiscount();
      productList.refresh();
    } catch (e) {
      print("🚨 Live Update Error: $e");
      showSnackBar(error: "Connection error. Please try again.");
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

  Future<void> fetchDiscounts() async {
    if (userId == null) return;

    try {
      final response = await SupabaseConfig.from(
        'discounts',
      ).select('*').eq('user_id', userId!);

      discountList.value =
          response.map((data) => DiscountModel.fromJson(data)).toList();
    } catch (e) {
      customMessageOrErrorPrint(message: "Discount Error: $e");
    }
  }

  Future<Map<String, dynamic>> prepareStockUpdate({
    required String userId,
    required ProductModel product,
  }) async {
    try {
      if (product.sellType?.toLowerCase() == 'loose') {
        // Loose stock update
        final response =
            await SupabaseConfig.from('loose_stocks')
                .select('id, quantity')
                .eq('user_id', userId)
                .eq('product_id', product.id ?? product.barcode ?? '')
                .maybeSingle();

        if (response == null) {
          throw Exception("Loose product not found: ${product.barcode}");
        }

        final currentQty = response['quantity'] ?? 0;
        final sellQty = product.quantity ?? 1;

        if (currentQty < sellQty) {
          throw Exception("Not enough loose stock for ${product.name}");
        }

        return {
          'table': 'loose_stocks',
          'id': response['id'],
          'newQty': currentQty - sellQty,
          'productId': product.id ?? product.barcode ?? '',
        };
      } else {
        // Regular product stock update
        final response =
            await SupabaseConfig.from('product_stock')
                .select('id, quantity')
                .eq('user_id', userId)
                .eq('product_id', product.id ?? product.barcode ?? '')
                .maybeSingle();

        if (response == null) {
          throw Exception("Product not found: ${product.barcode}");
        }

        final currentQty = response['quantity'] ?? 0;
        final sellQty = product.quantity ?? 1;

        if (currentQty < sellQty) {
          throw Exception("Not enough stock for ${product.name}");
        }

        return {
          'table': 'product_stock',
          'id': response['id'],
          'newQty': currentQty - sellQty,
          'productId': product.id ?? product.barcode ?? '',
        };
      }
    } catch (e) {
      print(e.toString());
      throw Exception("Stock check failed: $e");
    }
  }

  Future<bool> confirmSale({
    required List<SellItem> sellItems,
    required RxBool isLoading,
  }) async {
    isLoading.value = true;
    if (userId == null) return false;

    try {
      // 1. Stock Updates & Calculations
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

      // 2. Build Smart Payment Record (Matching your New Table Columns)
      double cash = double.tryParse(cashPaidController.text) ?? 0;
      double upi = double.tryParse(upiPaidController.text) ?? 0;
      double card = double.tryParse(cardPaidController.text) ?? 0;
      double credit = double.tryParse(creditPaidController.text) ?? 0;

      // Check if partial
      int modesCount = 0;
      if (cash > 0) modesCount++;
      if (upi > 0) modesCount++;
      if (card > 0) modesCount++;
      if (credit > 0) modesCount++;

      // 🎯 Ye Map aapke RPC ke JSONB parameter mein jayega
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

      // 3. Build Sale Items
      // 3. Build Sale Items (Keys exact database columns se match honi chahiye)
      final saleItemsData =
          sellItems
              .map(
                (item) => {
                  'product_id': item.id,
                  'qty': item.quantity,
                  'original_price':
                      item.originalPrice ??
                      item.finalPrice ??
                      0, // 👈 Null check add kiya
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

      // 4. 🔥 EXECUTE TRANSACTION
      final dynamic response = await SupabaseConfig.client.rpc(
        'process_sale_transaction',
        params: {
          'p_user_id': userId,
          'p_total_amount': finalPayable,
          'p_sale_items': saleItemsData,
          'p_payments': paymentRecords, // 🎯 Full Settlement Data sent here
          'p_stock_updates': stockUpdates,
        },
      );

      final Map<String, dynamic> result = jsonDecode(response.toString());

      final int databaseBillNo = result['bill_no'];

      // 5. Print Data
      final paymentMapForPrint = buildPaymentMap(
        totalAmount: itemsTotalAmount,
        cashPaid: cash,
        upiPaid: upi,
        cardPaid: card,
        creditPaid: credit,
        roundOffPaid: roundOff,
      );

      final saleData = {
        'billNo': databaseBillNo,
        'soldAt': setFormateDate(),
        'time': setFormateDate('hh:mm:ss a'),
        'totalAmount': finalPayable,
        'payment': paymentMapForPrint,
        'items': sellItems.map((e) => e.toJson()).toList(),
      };

      printInvoice.value = PrintInvoiceModel.fromJson(saleData);
      scannedProductDetails.clear();

      // Clear controllers after success
      cashPaidController.clear();
      upiPaidController.clear();
      cardPaidController.clear();
      creditPaidController.clear();
      roundOffPaidController.clear();

      return true;
    } catch (e) {
      print("🚨 Sale Failed: $e");
      showMessage(message: "Sale Error: $e");
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
    int paymentCount = 0;
    if (cashPaid > 0) paymentCount++;
    if (upiPaid > 0) paymentCount++;
    if (cardPaid > 0) paymentCount++;
    if (creditPaid > 0) paymentCount++;
    String type;
    if (paymentCount > 1) {
      type = "partial";
    } else if (cashPaid > 0) {
      type = "cash";
    } else if (upiPaid > 0) {
      type = "upi";
    } else if (cardPaid > 0) {
      type = "card";
    } else if (creditPaid > 0) {
      type = "credit";
    } else {
      type = "unknown";
    }
    bool isRoundOffApplied = roundOffPaid != 0;

    return {
      "type": type.capitalizeFirst,
      "totalAmount": totalAmount,
      "cash": cashPaid,
      "upi": upiPaid,
      "card": cardPaid,
      "credit": creditPaid,
      "roundOffAmount": roundOffPaid,
      "isRoundOff": isRoundOffApplied,
    };
  }

  List<SellItem> getPrintReadyList() {
    for (int i = 0; i < productList.length; i++) {
      var p = productList[i];
      var discount = int.parse(perProductDiscount[i].text);
      sellList.add(
        SellItem(
          name: p.name,
          quantity: p.quantity?.toInt() ?? 0,
          originalPrice: p.sellingPrice,
          originalDiscount: p.discount,
          discount: discount,
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



 //updateDashboardRevenue(finalAmount);

      // removelooseInvetoryKeyModel();
      //removePoductModel();

// void updateQuantity(bool isIncrement, int index) async {
  //   int? pexistingQty;
  //   int? existingLooseQty;
  //   final uid = _auth.currentUser?.uid;
  //   isStockOver.value = false;
  //   final productRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .collection('products')
  //       .doc(productList[index].barcode);
  //   final looseProductRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .collection('looseProducts')
  //       .doc(productList[index].barcode);
  //   final existingDoc = await productRef.get();
  //   final existingLooseDoc = await looseProductRef.get();
  //   if (existingDoc.exists) {
  //     pexistingQty = existingDoc['quantity'];
  //   }
  //   if (existingLooseDoc.exists) {
  //     existingLooseQty = existingLooseDoc['quantity'];
  //   }
  //   var current = productList[index];
  //   if (isIncrement) {
  //     if (pexistingQty != null) {
  //       if ((current.quantity ?? 0) < pexistingQty) {
  //         current.quantity = (current.quantity ?? 0) + 1;
  //       } else {
  //         isStockOver.value = true;
  //         showSnackBar(
  //           error:
  //               "Product is out of stock\nYou cannot add more than available stock.",
  //         );
  //       }
  //     } else if (existingLooseQty != null) {
  //       if ((current.quantity ?? 0) < existingLooseQty) {
  //         current.quantity = (current.quantity ?? 0) + 1;
  //       } else {
  //         isStockOver.value = true;
  //         showSnackBar(
  //           error:
  //               "Product is out of stock\nYou cannot add more than available stock.",
  //         );
  //       }
  //     }
  //   } else {
  //     if ((current.quantity ?? 1) > 1) {
  //       current.quantity = (current.quantity ?? 1) - 1;
  //     }
  //   }
  //   productList[index] = current;
  //   saveCartProductList(productList);
  //   discountCalculateAsPerProduct(index);
  //   calculateTotalWithDiscount();
  // }

  // Future<void> updateQuantity(bool isIncrement, int index) async {
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) return;

  //   isStockOver.value = false;
  //   var current = productList[index];

  //   int availableQty = 0;

  //   // ===============================
  //   // 1️⃣ FETCH STOCK BASED ON sellType
  //   // ===============================
  //   if (current.sellType?.toLowerCase() == 'loose') {
  //     final looseRef = FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(uid)
  //         .collection('looseProducts')
  //         .doc(current.barcode);

  //     final snap = await looseRef.get();
  //     if (!snap.exists) {
  //       showSnackBar(error: "Loose product stock not found");
  //       return;
  //     }

  //     availableQty = snap['quantity'] ?? 0;
  //   } else {
  //     final productRef =
  //         FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(uid)
  //             .collection('products')
  //             .where('barcode', isEqualTo: current.barcode)
  //             .limit(1)
  //             .get();

  //     final query = await productRef;
  //     if (query.docs.isEmpty) {
  //       showSnackBar(error: "Product stock not found");
  //       return;
  //     }

  //     availableQty = query.docs.first['quantity'] ?? 0;
  //   }

  //   // ===============================
  //   // 2️⃣ UPDATE QTY
  //   // ===============================
  //   if (isIncrement) {
  //     if ((current.quantity ?? 0) < availableQty) {
  //       current.quantity = (current.quantity ?? 0) + 1;
  //     } else {
  //       isStockOver.value = true;
  //       showSnackBar(
  //         error:
  //             "Product is out of stock\nYou cannot add more than available stock.",
  //       );
  //       return;
  //     }
  //   } else {
  //     if ((current.quantity ?? 1) > 1) {
  //       current.quantity = (current.quantity ?? 1) - 1;
  //     }
  //   }

  //   // ===============================
  //   // 3️⃣ SAVE & RECALCULATE
  //   // ===============================
  //   productList[index] = current;
  //   saveCartProductList(productList);

  //   discountCalculateAsPerProduct(index);
  //   calculateTotalWithDiscount();
  // }

  // 🚀 REMOVED - Bill generation now inside main transaction
  // Future<String> generateBillNo() async {
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) return "HBX0001";

  //   final counterRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .collection('bill')
  //       .doc('billNo');

  //   return FirebaseFirestore.instance.runTransaction((transaction) async {
  //     final snapshot = await transaction.get(counterRef);

  //     int newBillNo = 1;

  //     if (snapshot.exists) {
  //       newBillNo = (snapshot.data()?['lastBillNo'] ?? 0) + 1;
  //     }

  //     transaction.set(counterRef, {'lastBillNo': newBillNo});

  //     return "HB-$newBillNo";
  //   });
  // }

  // 🚀 REMOVED - Products fetched from cache only
  // Future<void> fetchAllProducts() async {
  //   final uid = _auth.currentUser?.uid;
  //   final productSnapshot =
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(uid)
  //           .collection('products')
  //           .where('quantity')
  //           .get();
  //   var productLists =
  //       productSnapshot.docs
  //           .map((doc) => ProductModel.fromJson(doc.data()))
  //           .toList();
  //   saveProductList(productLists);
  // }



  // Future<bool> confirmSale({
  //   required List<SellItem> sellItems,
  //   required RxBool isLoading,
  // }) async {
  //   isLoading.value = true;
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) return false;
  //   try {
  //     var now = DateTime.now();
  //     String formatDate = DateFormat('dd-MM-yyyy').format(now);
  //     String formatTime = DateFormat('hh:mm:ss a').format(now);
  //     List<Map<String, dynamic>> productUpdates = [];
  //     List<Map<String, dynamic>> items = []; // 👈 all items in one list
  //     double totalAmount = 0;
  //     double finalAmount = 0;
  //     // 🔹 STEP 1: Process each scanned product
  //     for (var product in scannedProductDetails) {
  //       if (product.barcode == null && product.id == null) continue;
  //       DocumentReference? productRef;
  //       Map<String, dynamic> productData = {};
  //       // 🔹 Fetch product details & update logic
  //       if (product.isLooseCategory == true || product.isLoosed == false) {
  //         // Loose Category Product
  //         productData = {
  //           'name': product.name ?? "",
  //           'category': product.category ?? "Loose Category",
  //           'flavours': product.flavor ?? "",
  //           'weight': product.weight ?? "0.0",
  //           'box': product.box ?? "0.0",
  //         };
  //       }
  //        else if (product.isLoosed == true ||
  //           product.isLooseCategory == false) {
  //         // Loose Product (from looseProducts)
  //         productRef = FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(uid)
  //             .collection('looseProducts')
  //             .doc(product.barcode);
  //         final snapshot = await productRef.get();
  //         if (!snapshot.exists) {
  //           showMessage(message: "❌ Loose product not found: ${product.id}");
  //           return false;
  //         }
  //         productData = snapshot.data() as Map<String, dynamic>;
  //         int currentQty = productData['quantity'] ?? 0;
  //         if (currentQty < (product.quantity ?? 1)) {
  //           showMessage(
  //             message: "❌ Not enough stock for ${productData['name']}",
  //           );
  //           return false;
  //         }
  //         // Add update for transaction
  //         productUpdates.add({
  //           "ref": productRef,
  //           "newQty": currentQty - (product.quantity ?? 1),
  //         });
  //       }
  //       else {
  //         // Normal Product (from products collection)
  //         final querySnapshot =
  //             await FirebaseFirestore.instance
  //                 .collection('users')
  //                 .doc(uid)
  //                 .collection('products')
  //                 .where('barcode', isEqualTo: product.barcode)
  //                 .limit(1)
  //                 .get();

  //         if (querySnapshot.docs.isEmpty) {
  //           showMessage(message: "❌ Product not found: ${product.barcode}");
  //           return false;
  //         }

  //         final snapshot = querySnapshot.docs.first;
  //         productRef = snapshot.reference;
  //         productData = snapshot.data();

  //         int currentQty = productData['quantity'] ?? 0;
  //         if (currentQty < (product.quantity ?? 1)) {
  //           showMessage(
  //             message: "❌ Not enough stock for ${productData['name']}",
  //           );
  //           return false;
  //         }

  //         productUpdates.add({
  //           "ref": productRef,
  //           "newQty": currentQty - (product.quantity ?? 1),
  //         });
  //       }
  //     }

  //     // 🔹 Generate Bill Number
  //     String newBillNo = await generateBillNo();

  //     // 🔹 STEP 2: Update inventory in transaction
  //     await FirebaseFirestore.instance.runTransaction((transaction) async {
  //       for (var update in productUpdates) {
  //         transaction.update(update['ref'], {
  //           'quantity': update['newQty'],
  //           'updatedDate': formatDate,
  //           'updatedTime': formatTime,
  //         });
  //       }
  //     });
  //     for (var item in sellItems) {
  //       totalAmount += item.originalPrice ?? 0;
  //       finalAmount += item.finalPrice ?? 0;
  //     }

  //     // 🔹 STEP 3: Save final sale document
  //     final paymentData = buildPaymentMap(
  //       totalAmount: totalAmount,
  //       roundOffPaid: double.parse(roundOffPaidController.text),
  //       cashPaid: double.parse(cashPaidController.text),
  //       upiPaid: double.parse(upiPaidController.text),
  //       cardPaid: double.parse(cardPaidController.text),
  //       creditPaid: double.parse(creditPaidController.text),
  //     );

  //     double roundOffAmount = double.tryParse(roundOffPaidController.text) ?? 0;
  //     double finalPayableAmount = double.parse(
  //       (finalAmount - roundOffAmount).toStringAsFixed(2),
  //     );
  //     final saleData = {
  //       'billNo': newBillNo,
  //       'soldAt': formatDate,
  //       'time': formatTime,
  //       'totalAmount': totalAmount,
  //       'discount': isDiscountGiven.value,
  //       'discountValue': discountValue.value,
  //       'finalAmount': finalPayableAmount,
  //       'itemsCount': items.length,
  //       'items': sellItems.map((e) => e.toJson()).toList(),
  //       'payment': paymentData,
  //     };
  //     printInvoice.value = PrintInvoiceModel.fromJson(saleData);
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(uid)
  //         .collection('sales')
  //         .add(saleData);
  //     fetchAllProducts();
  //     scannedProductDetails.clear();
  //     return true;
  //   } catch (e) {
  //     showMessage(message: "❌ Error: ${e.toString()}");
  //     return false;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }


// Future<void> fetchLooseCategory() async {
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) return;

  //   try {
  //     final snapshot =
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(uid)
  //             .collection('looseSellCategory')
  //             .get();

  //     looseCategoryModelList.value =
  //         snapshot.docs.map((doc) {
  //           final data = doc.data();
  //           data['id'] = doc.id;
  //           return LooseCategoryModel.fromJson(data);
  //         }).toList();
  //   } on FirebaseAuthException catch (e) {
  //     showMessage(message: e.toString());
  //   } finally {}
  // }


// Future<bool> confirmSale({required String paymentMethod}) async {
  //   isSaleLoading.value = false;
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) return false;

  //   try {
  //     var now = DateTime.now();
  //     String formatDate = DateFormat('dd-MM-yyyy').format(now);
  //     String formatTime = DateFormat('hh:mm a').format(now);

  //     List<Map<String, dynamic>> saleLogs = [];
  //     List<Map<String, dynamic>> productUpdates = [];

  //     // 🔹 STEP 1: Sare products process karo
  //     for (var product in scannedProductDetails) {
  //       print(product.name);
  //       print(product.isLooseCategory);
  //       print(product.isLoosed);
  //       print(product.barcode);
  //       if (product.barcode == null && product.id == null) continue;

  //       DocumentReference? productRef;
  //       Map<String, dynamic> productData = {};

  //       if (product.isLooseCategory == true || product.isLoosed == false) {
  //         // 🔹 Loose Category (no stock check, no inventory update)
  //         productData = {
  //           'name': product.name ?? "",
  //           'category': product.category ?? "Loose Category",
  //           'flavours': product.flavor ?? "",
  //           'weight': product.weight ?? "0.0",
  //           'box': product.box ?? "0.0",
  //         };
  //       } else if (product.isLoosed == true ||
  //           product.isLooseCategory == false) {
  //         // 🔹 Loose Product
  //         productRef = FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(uid)
  //             .collection('looseProducts')
  //             .doc(product.barcode);

  //         final snapshot = await productRef.get();
  //         if (!snapshot.exists) {
  //           showMessage(message: "❌ Loose product not found: ${product.id}");
  //           return false;
  //         }

  //         productData = snapshot.data() as Map<String, dynamic>;
  //         int currentQty = productData['quantity'] ?? 0;
  //         if (currentQty < (product.quantity ?? 1)) {
  //           showMessage(
  //             message: "❌ Not enough stock for ${productData['name']}",
  //           );
  //           return false;
  //         }

  //         // 🔹 Update list me store karo
  //         productUpdates.add({
  //           "ref": productRef,
  //           "newQty": currentQty - (product.quantity ?? 1),
  //         });
  //       } else {
  //         // 🔹 Normal Product
  //         final querySnapshot =
  //             await FirebaseFirestore.instance
  //                 .collection('users')
  //                 .doc(uid)
  //                 .collection('products')
  //                 .where('barcode', isEqualTo: product.barcode)
  //                 .limit(1)
  //                 .get();

  //         if (querySnapshot.docs.isEmpty) {
  //           showMessage(message: "❌ Product not found: ${product.barcode}");
  //           return false;
  //         }

  //         final snapshot = querySnapshot.docs.first;
  //         productRef = snapshot.reference;
  //         productData = snapshot.data();

  //         int currentQty = productData['quantity'] ?? 0;
  //         if (currentQty < (product.quantity ?? 1)) {
  //           showMessage(
  //             message: "❌ Not enough stock for ${productData['name']}",
  //           );
  //           return false;
  //         }

  //         // 🔹 Update list me store karo
  //         productUpdates.add({
  //           "ref": productRef,
  //           "newQty": currentQty - (product.quantity ?? 1),
  //         });
  //       }
  //       String newBillNo =
  //           'HBX${billNo.value}${DateTime.now().millisecondsSinceEpoch}';

  //       // 🔹 Sale log banao (sab me common)
  //       saleLogs.add({
  //         'billNo': newBillNo,
  //         'paymentMethod': paymentMethod,
  //         'barcode': product.barcode ?? "",
  //         'name': productData['name'] ?? "",
  //         'quantity': product.quantity ?? 1,
  //         'category': productData['category'] ?? "",
  //         'flavor': productData['flavours'] ?? "",
  //         'weight': productData['weight'] ?? "0.0",
  //         'soldAt': formatDate,
  //         'time': formatTime,
  //         'box': productData['box'] ?? "0.0",
  //         'sellingPrice': product.sellingPrice ?? 0,
  //         'amount': (product.sellingPrice ?? 0) * (product.quantity ?? 1),
  //         'discount': isDiscountGiven.value,
  //         'discountValue': discountValue.value,
  //         'finalAmount':
  //             isDiscountGiven.value
  //                 ? discountPrice.value
  //                 : (product.sellingPrice ?? 0) * (product.quantity ?? 1),
  //         'isLoose': product.isLoosed ?? false,
  //         'isLooseCategory': product.isLooseCategory ?? false,
  //       });
  //     }

  //     // 🔹 STEP 2: Transaction me sirf updates karo
  //     await FirebaseFirestore.instance.runTransaction((transaction) async {
  //       for (var update in productUpdates) {
  //         transaction.update(update['ref'], {
  //           'quantity': update['newQty'],
  //           'updatedDate': formatDate,
  //           'updatedTime': formatTime,
  //         });
  //       }
  //     });

  //     // 🔹 STEP 3: Sale logs save karo
  //     for (var log in saleLogs) {
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(uid)
  //           .collection('sales')
  //           .add(log);
  //     }

  //     scannedProductDetails.clear();
  //     return true;
  //   } catch (e) {
  //     showMessage(message: "❌ Error: ${e.toString()}");
  //     return false;
  //   } finally {
  //     isSaleLoading.value = false;
  //   }
  // }


  // Future<void> fetchDiscounts() async {
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) return;

  //   try {
  //     final snapshot =
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(uid)
  //             .collection('discounts')
  //             .get();
  //     discountList.value =
  //         snapshot.docs.map((doc) {
  //           final data = doc.data();
  //           data['id'] = doc.id;
  //           return DiscountModel.fromJson(data);
  //         }).toList();
  //   } on FirebaseAuthException catch (e) {
  //     showMessage(message: e.toString());
  //   }
  // }
