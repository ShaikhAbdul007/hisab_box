import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/set_format_date.dart';

import '../../../helper/app_message.dart';
import '../model/category_model.dart';

class CategoryController extends GetxController with CacheManager {
  final _auth = FirebaseAuth.instance;
  TextEditingController category = TextEditingController();
  RxBool isSaveLoading = false.obs;
  RxBool isDeleteCategory = false.obs;
  RxBool isFetchCategory = false.obs;
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;

  @override
  void onInit() {
    getCategoryData();
    super.onInit();
  }

  void getCategoryData() async {
    await fetchCategories();
  }

  Future<void> addAnimalCategory(String categoryName) async {
    isSaveLoading.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final now = DateTime.now();
      final docRef =
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('categories')
              .doc(); // 🔐 Auto ID

      final category = CategoryModel(
        time: setFormateDate('hh:mm a'),
        id: docRef.id,
        name: categoryName,
        createdAt: setFormateDate(),
      );

      await docRef.set(category.toJson());
      clear();
      Get.back();
      await fetchCategories();
      showMessage(message: categorySaveSuccessfull);
    } on FirebaseException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    isFetchCategory.value = true;
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('categories')
              .get();

      categoryList.value =
          snapshot.docs
              .map((doc) => CategoryModel.fromJson(doc.data()))
              .toList();
      saveCategoryModel(categoryList);
    } on FirebaseException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isFetchCategory.value = false;
    }
  }

  Future<void> deleteCategory(String aminalCategoryId) async {
    isDeleteCategory.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('categories')
          .doc(aminalCategoryId)
          .delete();
      showMessage(message: categorydeleteSuccessMessage);
      await fetchCategories();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isDeleteCategory.value = false;
    }
  }

  void clear() {
    category.clear();
  }
}
