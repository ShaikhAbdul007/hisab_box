import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/category/repo/animal_category_repo.dart';
import 'package:inventory/helper/app_message.dart';

class AnimalTypeController extends GetxController with CacheManager {
  AnimalCategoryRepo animalCategoryRepo = AnimalCategoryRepo();
  TextEditingController animalCategory = TextEditingController();
  RxBool isSaveLoading = false.obs;
  RxBool isDeleteAnimalCategory = false.obs;
  RxBool isFetchAnimalCategory = false.obs;
  RxString shopType = ''.obs;
  RxList<CategoryModelListData> animalTypeList = <CategoryModelListData>[].obs;
  var data = Get.arguments;

  @override
  void onInit() {
    getCategoryData();
    super.onInit();
  }

  void getCategoryData() async {
    await fetchCategories();
  }

  void setShopType() async {
    var user = retrieveUserDetail();
    shopType.value = user.data?.shopType ?? 'Pet Shop';
  }

  // ==========================================
  // 🔥 ADD ANIMAL CATEGORY (SUPABASE + HIVE)
  // ==========================================
  Future<void> addAnimalCategory(String categoryName) async {
    isSaveLoading.value = true;

    try {
      var body = {"name": categoryName};
      final response = await animalCategoryRepo.createAnimalCategory(
        body: body,
      );
      if (response.success == success) {
        Get.back();
        clear();
        await fetchCategories();
        showSnackBar(error: response.msg!, isError: false);
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }
    } catch (e) {
      clear();
      Get.back();
      showSnackBar(error: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  // ==========================================
  // 🔥 FETCH ANIMAL CATEGORIES (FALLBACK FLOW)
  // ==========================================
  Future<void> fetchCategories() async {
    isFetchAnimalCategory.value = true;
    try {
      var response = await animalCategoryRepo.getAnimalCategory();
      if (response.success == success) {
        animalTypeList.value = response.categorymodeldata?.data ?? [];
        saveAnimalList(animalTypeList);
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isFetchAnimalCategory.value = false;
    }
  }

  Future<void> deleteAnimalCategory(String animalCategoryId) async {
    isDeleteAnimalCategory.value = true;

    try {
      var response = await animalCategoryRepo.deleteAnimalCategory(
        id: animalCategoryId,
      );
      if (response.success == success) {
        showSnackBar(error: response.msg!, isError: false);
        await fetchCategories();
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isDeleteAnimalCategory.value = false;
    }
  }

  void clear() {
    animalCategory.clear();
  }
}
