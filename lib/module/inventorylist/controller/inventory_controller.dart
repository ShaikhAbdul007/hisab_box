import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';
import '../../../helper/helper.dart';

class InventoryListController extends GetxController with CacheManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var productList = <ProductModel>[].obs;
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

  @override
  void onInit() {
    fetchAllProducts();
    isInventoryScanSelectedValue();
    super.onInit();
  }

  void clear() {
    searchController.clear();
    searchText.value = '';
  }

  void controllerClear() {
    addSubtractQty.clear();
  }

  isInventoryScanSelectedValue() async {
    bool isInventoryScanSelecteds = await retrieveInventoryScan();
    isInventoryScanSelected.value = isInventoryScanSelecteds;
  }

  String getRandomHexColor() {
    final random = Random();
    final color = (random.nextDouble() * 0xFFFFFF).toInt();
    return '0xff${color.toRadixString(16).padLeft(6, '0')}';
  }

  Future<void> importProductsFromExcel() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      if (fileBytes == null) return;

      var excel = Excel.decodeBytes(fileBytes);

      for (var table in excel.tables.keys) {
        final rows = excel.tables[table]!.rows;

        for (int i = 1; i < rows.length; i++) {
          var row = rows[i];
          int finalQty = 0;

          if ((row[4]?.value.toString() ?? '').isNotEmpty) {
            finalQty = int.tryParse(row[4]?.value.toString() ?? '0') ?? 0;
          } else if ((row[2]?.value.toString() ?? '').isNotEmpty &&
              (row[3]?.value.toString() ?? '').isNotEmpty) {
            int box = int.tryParse(row[2]?.value.toString() ?? '0') ?? 0;
            int pcsPerBox = int.tryParse(row[3]?.value.toString() ?? '1') ?? 1;
            finalQty = box * pcsPerBox;
          }

          final Map<String, dynamic> data = {
            'barcode': row[0]?.value.toString() ?? '',
            'name': row[1]?.value.toString() ?? '',
            'quantity': finalQty,
            'sellingPrice':
                double.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
            'purchasePrice':
                double.tryParse(row[4]?.value.toString() ?? '0') ?? 0,
            'piecesPerBox': int.tryParse(row[5]?.value.toString() ?? '1') ?? 1,
            'flavours': row[6]?.value.toString() ?? '',
            'weight': row[7]?.value.toString() ?? '',
            'category': row[8]?.value.toString() ?? '',
            'animalType': row[9]?.value.toString() ?? '',
            'createdDate': DateFormat('dd-MM-yyyy').format(DateTime.now()),
            'createdTime': DateFormat('hh:mm a').format(DateTime.now()),
            'updatedDate': DateFormat('dd-MM-yyyy').format(DateTime.now()),
            'updatedTime': DateFormat('hh:mm a').format(DateTime.now()),
            'color': getRandomHexColor(),
          };

          // Upload to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('products')
              .doc(data['barcode'])
              .set(data);
        }
      }

      showMessage(message: "✅ Products uploaded successfully!");
    } else {
      showMessage(message: "❌ File picking cancelled");
    }
  }

  searchProduct(String value) {
    searchText.value = value;
    searchController.text = searchText.value;
  }

  setQuantitydata(int index) {
    isFlavorAndWeightNotRequired.value =
        productList[index].isFlavorAndWeightNotRequired ?? false;
    name.text = productList[index].name ?? '';
    updateQuantity.text = productList[index].quantity.toString();
    sellingPrice.text = productList[index].sellingPrice.toString();
    purchasePrice.text = productList[index].purchasePrice.toString();
    flavor.text = productList[index].flavor ?? '';
    weight.text = productList[index].weight.toString();
    print(productList[index].isLoosed);
    isLoose.value = productList[index].isLoosed ?? false;
  }

  updateProductQuantity({required String barcode}) async {
    isSaveLoading.value = true;
    try {
      final now = DateTime.now();
      final String formatDate = DateFormat('dd-MM-yyyy').format(now);
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      final productRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('products')
          .doc(barcode);
      final existingDoc = await productRef.get();

      if (existingDoc.exists) {
        // final prevQty = existingDoc['quantity'] ?? 0;
        // final newQty = int.tryParse(addSubtractQty.text) ?? 0;
        await productRef.update({
          'quantity': int.parse(updateQuantity.text),
          'purchasePrice': double.tryParse(purchasePrice.text) ?? 0.0,
          'sellingPrice': double.tryParse(sellingPrice.text) ?? 0.0,
          'name': name.text,
          'flavours': flavor.text,
          'isLoose': isLoose.value,
          'updatedDate': formatDate,
          'updatedTime': DateFormat('hh:mm a').format(now),
        });
        Get.back();
        controllerClear();
        showMessage(message: '✅ Product Info updated.');
        await fetchAllProducts();
      }
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  Future<void> fetchAllProducts() async {
    isDataLoading.value = true;
    final uid = _auth.currentUser?.uid;
    final productSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('products')
            .where('quantity', isGreaterThan: 0)
            .get();
    productList.value =
        productSnapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data()))
            .toList();

    isDataLoading.value = false;
  }
}
