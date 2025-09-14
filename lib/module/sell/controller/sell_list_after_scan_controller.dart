import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/routes/routes.dart';
import '../../discount/model/discount_model.dart';
import '../../../helper/helper.dart';
import '../../loose_category/model/loose_category_model.dart';

class SellListAfterScanController extends GetxController with CacheManager {
  var data = Get.arguments;
  late List<ProductModel> productList;
  String? id;
  RxDouble totalAmount = 0.0.obs;
  RxDouble newSellingPrice = 0.0.obs;
  RxInt discountValue = 0.obs;
  RxInt billNo = 0.obs;
  RxDouble updateSellingPrice = 0.0.obs;
  RxBool isSaleLoading = false.obs;
  RxBool isStockOver = false.obs;
  RxBool isDiscountGiven = false.obs;
  RxBool isPrintingLoading = false.obs;
  RxBool isSaveLoading = false.obs;
  TextEditingController amount = TextEditingController();
  double discountDifferenceAmount = 0.0;
  TextEditingController quantity = TextEditingController();
  TextEditingController name = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<ProductModel> scannedProductDetails = [];
  RxList<DiscountModel> discountList = <DiscountModel>[].obs;
  RxDouble discountPrice = 0.0.obs;
  RxList<LooseCategoryModel> looseCategoryModelList =
      <LooseCategoryModel>[].obs;
  Rx<ReceiptController?> receiptController = Rx<ReceiptController?>(null);
  @override
  void onInit() {
    fetchDiscounts();
    checkBluetoothConnectivity();
    productList = data['productList'];
    scannedProductDetails = productList;
    super.onInit();
  }

  Future<bool> checkBluetoothConnectivity() async {
    // Check pehle supported hai ya nahi
    if (await FlutterBluePlus.isSupported == false) {
      return false;
    }

    // Abhi current adapter state ka ek hi baar ka value lo
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;

    if (state == BluetoothAdapterState.on) {
      return true;
    } else {
      return false;
    }
  }

  void setReceiptController(ReceiptController controller) {
    receiptController.value = controller;
  }

  void calculateDiscount() {
    double originalAmount = getTotalAmount().toDouble();
    double discount = (originalAmount * discountValue.value) / 100;
    discountDifferenceAmount = discount;
    double discountedAmount = originalAmount - discount;
    discountPrice.value = discountedAmount;
    amount.text = discountedAmount.floorToDouble().toString();
  }

  int getTotalAmount() {
    int total = 0;
    for (var product in productList) {
      int price = (product.sellingPrice ?? 0).toInt();
      int qty = (product.quantity ?? 0).toInt();
      total += price * qty;
    }
    print("Total Amount: $total");
    return total;
  }

  void updateQuantity(
    ProductModel product,
    bool isIncrement,
    int index,
    String barcode,
  ) async {
    int? pexistingQty;
    int? existingLooseQty;

    final uid = _auth.currentUser?.uid;
    isStockOver.value = false;
    // Normal product reference
    final productRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('products')
        .doc(barcode);

    // Loose product reference (yaha barcode based doc nahi, pura collection h)
    final looseProductRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('looseProducts')
        .doc(
          product.barcode,
        ); // 👈 maan le tu product.id rakhta hai loose ke liye unique

    final existingDoc = await productRef.get();
    final existingLooseDoc = await looseProductRef.get();

    if (existingDoc.exists) {
      pexistingQty = existingDoc['quantity'];
    }
    if (existingLooseDoc.exists) {
      existingLooseQty = existingLooseDoc['quantity'];
    }

    var current = productList[index];

    if (isIncrement) {
      // agar normal product hai
      if (pexistingQty != null) {
        if ((current.quantity ?? 0) < pexistingQty) {
          current.quantity = (current.quantity ?? 0) + 1;
        } else {
          isStockOver.value = true;
          showSnackBar(
            error:
                "Product is out of stock\nYou cannot add more than available stock.",
          );
        }
      }
      // agar loose product hai
      else if (existingLooseQty != null) {
        if ((current.quantity ?? 0) < existingLooseQty) {
          current.quantity = (current.quantity ?? 0) + 1;
        } else {
          isStockOver.value = true;
          showSnackBar(
            error:
                "Product is out of stock\nYou cannot add more than available stock.",
          );
        }
      }
    } else {
      // Decrease qty but not below 1
      if ((current.quantity ?? 1) > 1) {
        current.quantity = (current.quantity ?? 1) - 1;
      }
    }

    productList[index] = current;
  }

  getSellingPriceAsPerQuantity(ProductModel product, int index) {
    double sellingPrice =
        (productList[index].sellingPrice!) *
        (productList[index].quantity!.toInt());

    print('sellingPrice is $sellingPrice');

    return sellingPrice;
  }

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

  Future<void> fetchDiscounts() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('discounts')
              .get();

      discountList.value =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return DiscountModel.fromJson(data);
          }).toList();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    }
  }

  Future<bool> confirmSale({required String paymentMethod}) async {
    isSaleLoading.value = false;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      var now = DateTime.now();
      String formatDate = DateFormat('dd-MM-yyyy').format(now);
      String formatTime = DateFormat('hh:mm a').format(now);

      List<Map<String, dynamic>> saleLogs = [];
      List<Map<String, dynamic>> productUpdates = [];

      // 🔹 STEP 1: Sare products process karo
      for (var product in scannedProductDetails) {
        print(product.name);
        print(product.isLooseCategory);
        print(product.isLoosed);
        print(product.barcode);
        if (product.barcode == null && product.id == null) continue;

        DocumentReference? productRef;
        Map<String, dynamic> productData = {};

        if (product.isLooseCategory == true || product.isLoosed == false) {
          // 🔹 Loose Category (no stock check, no inventory update)
          productData = {
            'name': product.name ?? "",
            'category': product.category ?? "Loose Category",
            'flavours': product.flavor ?? "",
            'weight': product.weight ?? "0.0",
            'box': product.box ?? "0.0",
          };
        } else if (product.isLoosed == true ||
            product.isLooseCategory == false) {
          // 🔹 Loose Product
          productRef = FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('looseProducts')
              .doc(product.barcode);

          final snapshot = await productRef.get();
          if (!snapshot.exists) {
            showMessage(message: "❌ Loose product not found: ${product.id}");
            return false;
          }

          productData = snapshot.data() as Map<String, dynamic>;
          int currentQty = productData['quantity'] ?? 0;
          if (currentQty < (product.quantity ?? 1)) {
            showMessage(
              message: "❌ Not enough stock for ${productData['name']}",
            );
            return false;
          }

          // 🔹 Update list me store karo
          productUpdates.add({
            "ref": productRef,
            "newQty": currentQty - (product.quantity ?? 1),
          });
        } else {
          // 🔹 Normal Product
          final querySnapshot =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('products')
                  .where('barcode', isEqualTo: product.barcode)
                  .limit(1)
                  .get();

          if (querySnapshot.docs.isEmpty) {
            showMessage(message: "❌ Product not found: ${product.barcode}");
            return false;
          }

          final snapshot = querySnapshot.docs.first;
          productRef = snapshot.reference;
          productData = snapshot.data();

          int currentQty = productData['quantity'] ?? 0;
          if (currentQty < (product.quantity ?? 1)) {
            showMessage(
              message: "❌ Not enough stock for ${productData['name']}",
            );
            return false;
          }

          // 🔹 Update list me store karo
          productUpdates.add({
            "ref": productRef,
            "newQty": currentQty - (product.quantity ?? 1),
          });
        }

        // 🔹 Sale log banao (sab me common)
        saleLogs.add({
          'billNo': billNo.value,
          'paymentMethod': paymentMethod,
          'barcode': product.barcode ?? "",
          'name': productData['name'] ?? "",
          'quantity': product.quantity ?? 1,
          'category': productData['category'] ?? "",
          'flavor': productData['flavours'] ?? "",
          'weight': productData['weight'] ?? "0.0",
          'soldAt': formatDate,
          'time': formatTime,
          'box': productData['box'] ?? "0.0",
          'sellingPrice': product.sellingPrice ?? 0,
          'amount': (product.sellingPrice ?? 0) * (product.quantity ?? 1),
          'discount': isDiscountGiven.value,
          'discountValue': discountValue.value,
          'finalAmount':
              isDiscountGiven.value
                  ? discountPrice.value
                  : (product.sellingPrice ?? 0) * (product.quantity ?? 1),
          'isLoose': product.isLoosed ?? false,
          'isLooseCategory': product.isLooseCategory ?? false,
        });
      }

      // 🔹 STEP 2: Transaction me sirf updates karo
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        for (var update in productUpdates) {
          transaction.update(update['ref'], {
            'quantity': update['newQty'],
            'updatedDate': formatDate,
            'updatedTime': formatTime,
          });
        }
      });

      // 🔹 STEP 3: Sale logs save karo
      for (var log in saleLogs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('sales')
            .add(log);
      }

      scannedProductDetails.clear();
      return true;
    } catch (e) {
      showMessage(message: "❌ Error: ${e.toString()}");
      return false;
    } finally {
      isSaleLoading.value = false;
    }
  }
}
