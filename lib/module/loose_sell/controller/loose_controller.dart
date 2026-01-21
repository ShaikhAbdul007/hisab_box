import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/set_format_date.dart';
import '../../../helper/helper.dart';
import '../../loose_category/model/loose_category_model.dart';
import '../model/loose_model.dart';

class LooseController extends GetxController with CacheManager {
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController updateQuantity = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController addSubtractQty = TextEditingController();
  TextEditingController newSellingPrice = TextEditingController();
  TextEditingController name = TextEditingController();
  RxBool isDataLoading = false.obs;
  RxBool isSaveLoading = false.obs;
  RxBool isInventoryScanSelected = false.obs;
  var productList = <LooseInvetoryModel>[].obs;
  String? id;
  RxList<LooseCategoryModel> looseCategoryModelList =
      <LooseCategoryModel>[].obs;
  RxString searchText = ''.obs;
  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    fetchLosseList();
    super.onInit();
  }

  void fetchLosseList() async {
    await fetchLooseProduct();
  }

  void isInventoryScanSelectedValue() async {
    bool isInventoryScanSelecteds = await retrieveInventoryScan();
    isInventoryScanSelected.value = isInventoryScanSelecteds;
  }

  void qtyClear() {
    addSubtractQty.clear();
  }

  void searchProduct(String value) {
    searchText.value = value;
    searchController.text = searchText.value;
  }

  void setQuantitydata(int index) {
    sellingPrice.text = productList[index].sellingPrice.toString();
    updateQuantity.text = productList[index].quantity.toString();
  }

  void updateProductQuantity({
    required String barcode,
    required bool add,
  }) async {
    isSaveLoading.value = true;
    try {
      final String formatDate = setFormateDate();
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      final productRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('looseProducts')
          .doc(barcode);
      final existingDoc = await productRef.get();

      if (existingDoc.exists) {
        final prevQty = existingDoc['quantity'] ?? 0;
        final newQty = int.tryParse(addSubtractQty.text) ?? 0;
        final sellingprice = int.tryParse(sellingPrice.text) ?? 0;
        if (prevQty == newQty) {
          Get.back();
        } else {
          await productRef.update({
            'quantity': add ? prevQty + newQty : prevQty - newQty,
            'updatedDate': formatDate,
            'sellingPrice': sellingprice,
            'updatedTime': setFormateDate('hh:mm a'),
          });
          removelooseInvetoryKeyModel();
          Get.back();
          qtyClear();
          showMessage(message: '✅ Product quantity updated.');
          await fetchLooseProduct();
        }
      }
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  Future<void> fetchLooseProduct() async {
    isDataLoading.value = true;

    // 1️⃣ Cache-first
    final cachedLooseProducts = await retrieveLoosedProductList();
    if (cachedLooseProducts.isNotEmpty) {
      productList.value = cachedLooseProducts;
      isDataLoading.value = false;
      return;
    }

    // 2️⃣ Firebase fallback
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      isDataLoading.value = false;
      return;
    }

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('looseProducts')
              .get();

      productList.value =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return LooseInvetoryModel.fromJson(data);
          }).toList();

      // 🔥 cache save
      saveLoosedProductList(productList);
    } catch (e) {
      showMessage(message: e.toString());
    } finally {
      isDataLoading.value = false;
    }
  }

  void clear() {
    quantity.clear();
    amount.clear();
  }
}
