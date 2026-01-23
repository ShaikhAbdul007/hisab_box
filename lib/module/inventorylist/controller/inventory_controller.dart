import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/inventory/model/product_model.dart';

class InventoryListController extends GetxController
    with GetSingleTickerProviderStateMixin, CacheManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var productList = <ProductModel>[].obs;
  var goDownProductList = <ProductModel>[].obs;
  var shopProductList = <ProductModel>[].obs;
  RxBool isDataLoading = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool isInventoryScanSelected = false.obs;
  RxBool isSea = false.obs;
  RxBool isLoose = false.obs;
  RxBool isFlavorAndWeightNotRequired = false.obs;
  RxString searchText = ''.obs;
  TextEditingController updateQuantity = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController flavor = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController purchasePrice = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController addSubtractQty = TextEditingController();
  TabController? tabController;

  @override
  void onInit() {
    fetchAllProducts();
    isInventoryScanSelectedValue();
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
  }

  void setListAsPerType() {
    shopProductList
      ..clear()
      ..addAll(
        productList.where((p) => (p.location ?? '').toLowerCase() == 'shop'),
      );

    goDownProductList
      ..clear()
      ..addAll(
        productList.where((p) => (p.location ?? '').toLowerCase() == 'godown'),
      );
  }

  void clear() {
    searchController.clear();
    searchText.value = '';
  }

  void controllerClear() {
    addSubtractQty.clear();
  }

  void isInventoryScanSelectedValue() async {
    bool isInventoryScanSelecteds = await retrieveInventoryScan();
    isInventoryScanSelected.value = isInventoryScanSelecteds;
  }

  void searchProduct(String value) {
    searchText.value = value;
    searchController.text = searchText.value;
  }

  Future<void> fetchAllProducts() async {
    isDataLoading.value = true;

    var cacheProductList = await retrieveProductList();

    if (cacheProductList.isNotEmpty) {
      productList.value = cacheProductList;
      setListAsPerType();
      isDataLoading.value = false;
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      isDataLoading.value = false;
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

    saveProductList(productList);
    setListAsPerType();
    isDataLoading.value = false;
  }
}



  // String getRandomHexColor() {
  //   final random = Random();
  //   final color = (random.nextDouble() * 0xFFFFFF).toInt();
  //   return '0xff${color.toRadixString(16).padLeft(6, '0')}';
  // }



  // Future<void> importProductsFromExcel() async {
  //   final uid = _auth.currentUser?.uid;
  //   if (uid == null) return;

  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['xlsx', 'xls'],
  //   );

  //   if (result != null) {
  //     Uint8List? fileBytes = result.files.first.bytes;
  //     if (fileBytes == null) return;

  //     var excel = Excel.decodeBytes(fileBytes);

  //     for (var table in excel.tables.keys) {
  //       final rows = excel.tables[table]!.rows;

  //       for (int i = 1; i < rows.length; i++) {
  //         var row = rows[i];
  //         int finalQty = 0;

  //         if ((row[4]?.value.toString() ?? '').isNotEmpty) {
  //           finalQty = int.tryParse(row[4]?.value.toString() ?? '0') ?? 0;
  //         } else if ((row[2]?.value.toString() ?? '').isNotEmpty &&
  //             (row[3]?.value.toString() ?? '').isNotEmpty) {
  //           int box = int.tryParse(row[2]?.value.toString() ?? '0') ?? 0;
  //           int pcsPerBox = int.tryParse(row[3]?.value.toString() ?? '1') ?? 1;
  //           finalQty = box * pcsPerBox;
  //         }

  //         final Map<String, dynamic> data = {
  //           'barcode': row[0]?.value.toString() ?? '',
  //           'name': row[1]?.value.toString() ?? '',
  //           'quantity': finalQty,
  //           'sellingPrice':
  //               double.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
  //           'purchasePrice':
  //               double.tryParse(row[4]?.value.toString() ?? '0') ?? 0,
  //           'piecesPerBox': int.tryParse(row[5]?.value.toString() ?? '1') ?? 1,
  //           'flavours': row[6]?.value.toString() ?? '',
  //           'weight': row[7]?.value.toString() ?? '',
  //           'category': row[8]?.value.toString() ?? '',
  //           'animalType': row[9]?.value.toString() ?? '',
  //           'createdDate': DateFormat('dd-MM-yyyy').format(DateTime.now()),
  //           'createdTime': DateFormat('hh:mm a').format(DateTime.now()),
  //           'updatedDate': DateFormat('dd-MM-yyyy').format(DateTime.now()),
  //           'updatedTime': DateFormat('hh:mm a').format(DateTime.now()),
  //           'color': getRandomHexColor(),
  //         };

  //         // Upload to Firestore
  //         await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(uid)
  //             .collection('products')
  //             .doc(data['barcode'])
  //             .set(data);
  //       }
  //     }
  //     showMessage(message: "✅ Products uploaded successfully!");
  //   } else {
  //     showMessage(message: "❌ File picking cancelled");
  //   }
  // }