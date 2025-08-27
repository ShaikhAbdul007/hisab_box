import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/routes/routes.dart';

import '../../discount/model/discount_model.dart';
import '../../../helper/helper.dart';
import '../../loose_category/model/loose_category_model.dart';

class SellListAfterScanController extends GetxController {
  var data = Get.arguments;
  late List<ProductModel> productList;
  String? id;
  RxDouble totalAmount = 0.0.obs;
  RxDouble newSellingPrice = 0.0.obs;
  RxInt discountValue = 0.obs;
  RxDouble updateSellingPrice = 0.0.obs;
  RxBool isSaleLoading = false.obs;
  RxBool isLooseSell = false.obs;
  RxBool isDiscountGiven = false.obs;
  RxBool isSaveLoading = false.obs;
  TextEditingController amount = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController name = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<ProductModel> scannedProductDetails = [];
  RxList<DiscountModel> discountList = <DiscountModel>[].obs;
  RxDouble discountPrice = 0.0.obs;
  RxList<LooseCategoryModel> looseCategoryModelList =
      <LooseCategoryModel>[].obs;
  @override
  void onInit() {
    fetchDiscounts();
    fetchLooseCategory();
    productList = data['productList'];
    scannedProductDetails = productList;
    super.onInit();
  }

  void calculateDiscount() {
    double originalAmount = getTotalAmount().toDouble();
    double discount = (originalAmount * discountValue.value) / 100;
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
    final uid = _auth.currentUser?.uid;
    final productRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('products')
        .doc(barcode);

    final existingDoc = await productRef.get();
    if (existingDoc.exists) {
      pexistingQty = existingDoc['quantity'];
    }

    var current = productList[index];

    if (isIncrement) {
      // 🔥 check karo ki current quantity < database quantity
      if ((current.quantity ?? 0) < (pexistingQty ?? 0)) {
        current.quantity = (current.quantity ?? 0) + 1;
      } else {
        // agar stock se zyada add karna try kare
        Get.snackbar(
          "Out of Stock",
          "You cannot add more than available stock (${pexistingQty ?? 0}).",
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.redColor,
          colorText: AppColors.whiteColor,
        );
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

  Future<void> fetchLooseCategory() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('looseSellCategory')
              .get();

      looseCategoryModelList.value =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return LooseCategoryModel.fromJson(data);
          }).toList();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    } finally {}
  }

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

  Future<void> confirmSale() async {
    isSaleLoading.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      List<Map<String, dynamic>> saleLogs = [];

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        for (var product in scannedProductDetails) {
          if (product.barcode == null) continue;

          // 🔹 Step 1: Firestore se product fetch karo
          final querySnapshot =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('products')
                  .where('barcode', isEqualTo: product.barcode)
                  .limit(1)
                  .get();

          if (querySnapshot.docs.isEmpty) {
            throw Exception('Product not found: ${product.barcode}');
          }

          final snapshot = querySnapshot.docs.first;
          final productRef = snapshot.reference;

          final productData = snapshot.data() as Map<String, dynamic>;
          int currentQty = productData['quantity'] ?? 0;
          // print(
          //   "🔹 Barcode: ${product.barcode} | CurrentQty: $currentQty | SellQty: ${totalQty} | NewQty: $newQty",
          // );
          var now = DateTime.now();
          String formatDate = DateFormat('dd-MM-yyyy').format(now);
          String formatTime = DateFormat('hh:mm a').format(now);

          // 🔹 Step 2: Quantity update karo
          transaction.update(productRef, {
            'quantity':
                currentQty -
                (product.quantity ?? 1), // ek product ka qty use karo
            'updatedDate': formatDate,
            'updatedTime': formatTime,
          });

          // 🔹 Step 3: Sale log banao
          saleLogs.add({
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
          });
        }
      });

      // 🔸 Step 4: Write logs outside transaction
      for (var log in saleLogs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('sales')
            .add(log);
      }

      scannedProductDetails.clear();
      showMessage(message: "✅ Success! products sold.");
      AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
    } on FirebaseException catch (e) {
      showMessage(message: "❌ Error: ${e.toString()}");
    } catch (e) {
      showMessage(message: "❌ Error: ${e.toString()}");
    } finally {
      isSaleLoading.value = false;
    }
  }
}
