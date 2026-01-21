import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:inventory/module/loose_sell/model/loose_model.dart';
import 'package:inventory/module/revenue/model/revenue_model.dart';
import '../../../helper/helper.dart';
import '../../../helper/set_format_date.dart';
import '../../../routes/route_name.dart';
import '../../sell/model/sell_model.dart';
import '../model/grid_model.dart';

// class HomeController extends GetxController with CacheManager {
//   final _auth = FirebaseAuth.instance;
//   RxDouble totalBusRevenue = 0.0.obs;
//   RxNum stock = RxNum(0);
//   RxNum sellStock = RxNum(0);
//   RxNum totalExpense = RxNum(0);
//   RxNum looseStock = RxNum(0);
//   RxNum outOfStock = RxNum(0);
//   List<CustomGridModel> lis = [];
//   RxBool isListLoading = false.obs;
//   List<Map<String, dynamic>> chartData = [];
//   final scrollController = ScrollController();
//   var sellsList = <SellsModel>[].obs;
//   FirebaseAuth get auth => _auth;
//   @override
//   void onInit() {
//     getRevenveAndStock();
//     super.onInit();
//   }

//   Future<void> getRevenveAndStock() async {
//     isListLoading.value = true;
//     await fetchPieChartData();
//     await getTotalRevenue();
//     await getTotalStock();
//     await getOutOfStock();
//     await getTotalLooseStock();
//     //await getTotalSoldQuantity();
//     await getTotalExpenses();
//     await getDashBoardList();
//     await setSellList();
//     isListLoading.value = false;
//   }

//   Future<void> setSellList() async {
//     sellsList.value = await fetchRevenueList();
//   }

//   Future<List<SaleModel>> fetchSales() async {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return [];
//     final today = setFormateDate();
//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(uid)
//             .collection('sales')
//             .orderBy('soldAt', descending: true)
//             .where('soldAt', isEqualTo: today)
//             .get();

//     final Map<String, SaleModel> salesByBarcode = {};
//     for (var doc in snapshot.docs) {
//       final sale = SaleModel.fromMap(doc.data());
//       final barcode = sale.barcode;
//       if (salesByBarcode.containsKey(barcode)) {
//         final existingSale = salesByBarcode[barcode]!;
//         salesByBarcode[barcode] = SaleModel(
//           animalType: existingSale.animalType,
//           sellingPrice: existingSale.sellingPrice,
//           barcode: existingSale.barcode,
//           quantity: (existingSale.quantity) + (sale.quantity),
//           soldAt: existingSale.soldAt,
//           name: existingSale.name,
//           category: existingSale.category,
//           time: existingSale.time,
//           weight: existingSale.weight,
//           amount: existingSale.amount,
//           flavor: existingSale.flavor,
//           discountPercentage: existingSale.discountPercentage,
//           amountAfterDiscount: existingSale.amountAfterDiscount,
//         );
//       } else {
//         salesByBarcode[barcode] = sale;
//       }
//     }

//     return salesByBarcode.values.toList();
//   }

//   Future<List<SellsModel>> fetchRevenueList() async {
//     try {
//       final today = setFormateDate();
//       final uid = _auth.currentUser?.uid;
//       if (uid == null) return [];

//       // 🔹 Fetch sales data from Firestore
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(uid)
//               .collection('sales')
//               .where('soldAt', isEqualTo: today)
//               .get();
//       final List<SellsModel> bills =
//           snapshot.docs.map((doc) {
//             final data = doc.data();
//             return SellsModel.fromJson(data);
//           }).toList();

//       customMessageOrErrorPrint(
//         message: '✅ Total Bills Fetched: ${bills.length}',
//       );
//       if (bills.isNotEmpty) {
//         customMessageOrErrorPrint(
//           message:
//               'First Bill: ${bills.first.billNo} — ₹${bills.first.finalAmount}',
//         );
//       }

//       return bills;
//     } catch (e) {
//       showMessage(message: "❌ Error fetching revenue: ${e.toString()}");
//       return [];
//     }
//   }

//   Future<void> fetchPieChartData() async {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return;

//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(uid)
//             .collection('sales')
//             .get();

//     // 🔁 Group by product name
//     Map<String, double> grouped = {};
//     for (var doc in snapshot.docs) {
//       final data = doc.data();
//       String name = data['name'] ?? 'Unknown';
//       double value = (data['finalAmount'] ?? 0).toDouble();

//       if (grouped.containsKey(name)) {
//         grouped[name] = grouped[name]! + value;
//       } else {
//         grouped[name] = value;
//       }
//     }

//     chartData =
//         grouped.entries.map((e) => {'label': e.key, 'value': e.value}).toList();
//   }

//   Future getTotalRevenue() async {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return 0;

//     final todayDate = setFormateDate();

//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(uid)
//             .collection('sales')
//             .where('soldAt', isEqualTo: todayDate)
//             .get();

//     double totalRevenue = 0;

//     for (var doc in snapshot.docs) {
//       double price;
//       if (doc.data().containsKey('finalAmount') &&
//           (doc['finalAmount'] ?? 0) > 0) {
//         price = (doc['finalAmount'] ?? 0).toDouble();
//       } else {
//         price = (doc['totalAmount'] ?? 0).toDouble();
//       }

//       totalRevenue += price;
//     }

//     totalBusRevenue.value = totalRevenue.floorToDouble();
//   }

//   Future getOutOfStock() async {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return 0;

//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(uid)
//             .collection('products')
//             .where('quantity', isEqualTo: 0)
//             .get();

//     // yaha se direct count mil jayega
//     int outOfStockCount = snapshot.docs.length;

//     // agar observable rakha h to update kar do
//     outOfStock.value = outOfStockCount.toDouble();
//   }

//   Future getTotalStock() async {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return 0;

//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(uid)
//             .collection('products')
//             .get();

//     int productCount = snapshot.docs.length;

//     stock.value = productCount;
//   }

//   Future getTotalLooseStock() async {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return 0;

//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(uid)
//             .collection('looseProducts')
//             .get();

//     num totalStock = 0;
//     if (snapshot.docs.isNotEmpty) {
//       for (var doc in snapshot.docs) {
//         totalStock += (doc['quantity'] ?? 0);
//       }
//     }

//     looseStock.value = totalStock;
//   }

//   Future getTotalSoldQuantity() async {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return 0;
//     final todayDate = setFormateDate();
//     final snapshot =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(uid)
//             .collection('sales')
//             .where('soldAt', isEqualTo: todayDate)
//             .get();

//     num totalSold = 0;

//     for (var doc in snapshot.docs) {
//       totalSold += (doc['quantity'] ?? 0);
//     }

//     sellStock.value = totalSold;
//   }

//   Future<void> getTotalExpenses() async {
//     final uid = _auth.currentUser?.uid;
//     final todayDate = setFormateDate();
//     if (uid == null) {}

//     try {
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(uid)
//               .collection('expenses')
//               .where('soldAt', isEqualTo: todayDate)
//               .get();

//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         final amount = data['amount'];
//         totalExpense.value = amount;
//       }
//     } on FirebaseException catch (e) {
//       showMessage(message: e.toString());
//     }
//   }

//   Future<void> getDashBoardList() async {
//     lis = [
//       // CustomGridModel(
//       //   routeName: AppRouteName.generateBarcode,
//       //   label: 'Barcode',
//       //   icon: CupertinoIcons.barcode,
//       //   numbers: double.parse(looseStock.value.toString()),
//       // ),
//       CustomGridModel(
//         routeName: AppRouteName.inventroyList,
//         label: 'Total Products',
//         icon: CupertinoIcons.cube_fill,
//         numbers: double.parse(stock.value.toString()),
//       ),
//       CustomGridModel(
//         routeName: AppRouteName.outOfStock,
//         icon: CupertinoIcons.cube_box,
//         label: 'Out Of Stock',
//         numbers: double.parse(outOfStock.value.toString()),
//       ),
//       // CustomGridModel(
//       //   icon: CupertinoIcons.square_list_fill,
//       //   routeName: AppRouteName.sell,
//       //   label: 'Sell',
//       //   numbers: double.parse(sellStock.value.toString()),
//       // ),
//       CustomGridModel(
//         routeName: AppRouteName.revenueView,
//         label: 'Today Sales',
//         icon: Icons.paid,
//         numbers: totalBusRevenue.value,
//       ),
//       // CustomGridModel(
//       //   routeName: AppRouteName.expense,
//       //   icon: Icons.money,
//       //   label: 'Expenses',
//       //   numbers: double.parse(totalExpense.value.toString()),
//       // ),
//       CustomGridModel(
//         routeName: AppRouteName.looseSell,
//         label: 'Loose Stock',
//         icon: CupertinoIcons.info,
//         numbers: double.parse(looseStock.value.toString()),
//       ),
//     ];
//   }
// }
class HomeController extends GetxController with CacheManager {
  final _auth = FirebaseAuth.instance;

  RxDouble totalBusRevenue = 0.0.obs;
  RxNum stock = RxNum(0);
  RxNum sellStock = RxNum(0);
  RxNum totalExpense = RxNum(0);
  RxNum looseStock = RxNum(0);
  RxNum outOfStock = RxNum(0);
  var productList = <ProductModel>[].obs;
  List<CustomGridModel> lis = [];
  RxBool isListLoading = false.obs;
  List<Map<String, dynamic>> chartData = [];
  var sellsList = <SellsModel>[].obs;
  RxList<LooseInvetoryModel> looseInventoryLis = <LooseInvetoryModel>[].obs;
  FirebaseAuth get auth => _auth;

  @override
  void onInit() {
    loadDashboard();
    super.onInit();
  }

  // ================= MAIN =================

  Future<void> loadDashboard() async {
    isListLoading.value = true;

    final cache = getDashboardCache();

    if (cache != null) {
      final updatedAt = cache['updatedAt'] ?? 0;

      if (_isSameDay(updatedAt)) {
        _loadFromCache();
      } else {
        await _loadFromFirebase();
        _saveToCache();
      }
    } else {
      await _loadFromFirebase();
      _saveToCache();
    }

    await getDashBoardList();
    isListLoading.value = false;
  }

  // ================= CACHE =================

  void _loadFromCache() {
    final data = getDashboardCache();
    if (data == null) return;

    totalBusRevenue.value = (data['totalRevenue'] ?? 0).toDouble();
    stock.value = data['stock'] ?? 0;
    looseStock.value = data['looseStock'] ?? 0;
    outOfStock.value = data['outOfStock'] ?? 0;
    totalExpense.value = data['expense'] ?? 0;

    chartData = List<Map<String, dynamic>>.from(data['chartData'] ?? []);

    sellsList.value =
        (data['sellsList'] as List?)
            ?.map((e) => SellsModel.fromJson(e))
            .toList() ??
        [];
  }

  void _saveToCache() {
    saveDashboardCache(
      totalRevenue: totalBusRevenue.value,
      stock: stock.value,
      looseStock: looseStock.value,
      outOfStock: outOfStock.value,
      expense: totalExpense.value,
      chartData: chartData,
      sellsList: sellsList,
    );
  }

  // ================= FIREBASE (FALLBACK ONLY) =================

  Future<void> _loadFromFirebase() async {
    await getTotalRevenue();
    await getTotalStock();
    await getOutOfStock();
    await getTotalLooseStock();
    // await getTotalExpenses();
    sellsList.value = await fetchRevenueList();
    // await fetchPieChartData();
  }

  // ================= EXISTING FUNCTIONS =================

  Future<void> getTotalRevenue() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final todayDate = setFormateDate();
    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('sales')
            .where('soldAt', isEqualTo: todayDate)
            .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc['finalAmount'] ?? doc['totalAmount'] ?? 0).toDouble();
    }

    totalBusRevenue.value = total;
  }

  Future<void> getTotalStock() async {
    final products = await retrieveProductList();
    if (products.isNotEmpty) {
      stock.value = products.length;
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return;
    }
    final productSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('products')
            .where('isActive', isEqualTo: true)
            .get();
    productList.value =
        productSnapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data()))
            .toList();
    stock.value = productList.length;
    saveProductList(productList);
  }

  Future<void> getOutOfStock() async {
    final products = await retrieveProductList();
    outOfStock.value = products.where((e) => (e.quantity ?? 0) == 0).length;
  }

  bool _isSameDay(int lastUpdatedMillis) {
    final last = DateTime.fromMillisecondsSinceEpoch(lastUpdatedMillis);
    final now = DateTime.now();

    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }

  Future<void> getTotalLooseStock() async {
    final uid = _auth.currentUser?.uid;
    final loose = await retrieveLoosedProductList();
    if (loose.isNotEmpty) {
      looseStock.value = loose.length;
      return;
    }

    if (uid == null) {
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('looseProducts')
            .where('isActive', isEqualTo: true)
            .get();

    looseInventoryLis.value =
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          //    looseOldQty = data['quantity'];

          return LooseInvetoryModel.fromJson(data);
        }).toList();
    saveLoosedProductList(looseInventoryLis);
  }

  //

  Future<List<SellsModel>> fetchRevenueList() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final todayDate = setFormateDate();

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('sales')
            .where('soldAt', isEqualTo: todayDate)
            .get();

    return snapshot.docs.map((doc) => SellsModel.fromJson(doc.data())).toList();
  }

  Future<void> getDashBoardList() async {
    lis = [
      CustomGridModel(
        routeName: AppRouteName.inventroyList,
        label: 'Total Products',
        icon: CupertinoIcons.cube_fill,
        numbers: stock.value.toDouble(),
      ),
      CustomGridModel(
        routeName: AppRouteName.outOfStock,
        icon: CupertinoIcons.cube_box,
        label: 'Out Of Stock',
        numbers: outOfStock.value.toDouble(),
      ),
      CustomGridModel(
        routeName: AppRouteName.revenueView,
        label: 'Today Sales',
        icon: Icons.paid,
        numbers: totalBusRevenue.value,
      ),
      CustomGridModel(
        routeName: AppRouteName.looseSell,
        label: 'Loose Stock',
        icon: CupertinoIcons.info,
        numbers: looseStock.value.toDouble(),
      ),
    ];
  }
}

  // Future<void> fetchPieChartData() async {
  //   // final uid = _auth.currentUser?.uid;
  //   // if (uid == null) return;

  //   // final snapshot =
  //   //     await FirebaseFirestore.instance
  //   //         .collection('users')
  //   //         .doc(uid)
  //   //         .collection('sales')
  //   //         .get();

  //   // final Map<String, double> grouped = {};

  //   // for (var doc in snapshot.docs) {
  //   //   final name = doc['name'] ?? 'Unknown';
  //   //   final value = (doc['finalAmount'] ?? 0).toDouble();
  //   //   grouped[name] = (grouped[name] ?? 0) + value;
  //   // }

  //   // chartData =
  //   //     grouped.entries.map((e) => {'label': e.key, 'value': e.value}).toList();
  // }


//Future<void> getTotalExpenses() async {
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) return;

  //   final todayDate = setFormateDate();

  //   final snapshot =
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(uid)
  //           .collection('expenses')
  //           .where('soldAt', isEqualTo: todayDate)
  //           .get();

  //   totalExpense.value = snapshot.docs.fold(
  //     0,
  //     (sum, e) => sum + (e['amount'] ?? 0),
  //   );
  // }