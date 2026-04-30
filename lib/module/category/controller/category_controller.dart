import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Mixin
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/category/repo/category_repo.dart';
import '../../../helper/app_message.dart';
import '../model/category_model.dart';

class CategoryController extends GetxController
    with CacheManager, LocalService {
  CategoryRepo categoryRepo = CategoryRepo();
  TextEditingController category = TextEditingController();
  RxBool isSaveLoading = false.obs;
  RxBool isDeleteCategory = false.obs;
  RxBool isFetchCategory = false.obs;
  RxList<CategoryModelListData> categoryList = <CategoryModelListData>[].obs;

  @override
  void onInit() {
    getCategoryData();
    super.onInit();
  }

  void getCategoryData() async {
    await fetchCategories();
  }

  Future<void> addCategory(String categoryName) async {
    isSaveLoading.value = true;

    try {
      var body = {"name": categoryName};
      final response = await categoryRepo.createCategory(body: body);
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

  Future<void> fetchCategories() async {
    isFetchCategory.value = true;

    try {
      var response = await categoryRepo.getCategory();
      if (response.success == success) {
        categoryList.value = response.categorymodeldata?.data ?? [];
        saveCategoryList(categoryList);
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isFetchCategory.value = false;
    }
  }

  Future<void> deleteCategory(String aminalCategoryId) async {
    isDeleteCategory.value = true;

    try {
      var response = await categoryRepo.deleteCategory(id: aminalCategoryId);
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
      isDeleteCategory.value = false;
    }
  }

  void clear() {
    category.clear();
  }
}
