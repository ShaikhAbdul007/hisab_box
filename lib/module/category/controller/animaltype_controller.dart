import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../model/category_model.dart';

class AnimalTypeController extends GetxController {
  final _auth = FirebaseAuth.instance;
  TextEditingController animalCategory = TextEditingController();
  RxBool isSaveLoading = false.obs;
  RxBool isDeleteAnimalCategory = false.obs;
  RxBool isFetchAnimalCategory = false.obs;
  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;

  @override
  void onInit() {
    getCategoryData();
    super.onInit();
  }

  getCategoryData() async {
    await fetchCategories();
  }

  Future<void> addCategory(String categoryName) async {
    isSaveLoading.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final now = DateTime.now();
      final docRef =
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('animalCategories')
              .doc();

      final category = CategoryModel(
        time: DateFormat('hh:mm a').format(now),
        id: docRef.id,
        name: categoryName,
        createdAt: DateFormat('dd-MM-yyyy').format(now),
      );

      await docRef.set(category.toJson());
      showMessage(message: animalTypeCategorySaveSuccessfull);
      clear();
      Get.back();
      await fetchCategories();
    } on FirebaseException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    isFetchAnimalCategory.value = true;
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('animalCategories')
              .get();
      animalTypeList.value =
          snapshot.docs
              .map((doc) => CategoryModel.fromJson(doc.data()))
              .toList();
    } on FirebaseException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isFetchAnimalCategory.value = false;
    }
  }

  Future<void> deleteAnimalCategory(String aminalCategoryId) async {
    isDeleteAnimalCategory.value = true;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('animalCategories')
          .doc(aminalCategoryId)
          .delete();
      showMessage(message: animalcategorydeleteSuccessMessage);
      await fetchCategories();
    } on FirebaseAuthException catch (e) {
      showMessage(message: e.toString());
    } finally {
      isDeleteAnimalCategory.value = false;
    }
  }

  clear() {
    animalCategory.clear();
  }
}
