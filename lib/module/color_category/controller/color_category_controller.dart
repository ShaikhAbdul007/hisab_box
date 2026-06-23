import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/color_category/repo/color_category_repo.dart';

class ColorCategoryController extends GetxController with CacheManager {
  ColorCategoryRepo colorCategoryRepo = ColorCategoryRepo();
  TextEditingController colorName = TextEditingController();

  RxBool isSaveLoading = false.obs;
  RxBool isDeleteLoading = false.obs;
  RxBool isFetchLoading = false.obs;
  RxList<CategoryModelListData> colorList = <CategoryModelListData>[].obs;

  @override
  void onInit() {
    fetchColors();
    super.onInit();
  }

  Future<void> fetchColors() async {
    isFetchLoading.value = true;
    try {
      final response = await colorCategoryRepo.getColorCategories();
      if (response.success == success) {
        colorList.value = response.data ?? [];
        saveColorCategoryList(colorList);
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isFetchLoading.value = false;
    }
  }

  Future<void> addColor(String name) async {
    isSaveLoading.value = true;
    try {
      final response = await colorCategoryRepo.createColorCategory(
        body: {"name": name},
      );
      if (response.success == success) {
        Get.back();
        clear();
        await fetchColors();
        showSnackBar(error: 'Color added successfully', isError: false);
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      clear();
      Get.back();
      showSnackBar(error: e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  Future<void> deleteColor(String id) async {
    isDeleteLoading.value = true;
    try {
      final response = await colorCategoryRepo.deleteColorCategory(id: id);
      if (response.success == success) {
        showSnackBar(error: 'Color deleted successfully', isError: false);
        await fetchColors();
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
        showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      showSnackBar(error: e.toString());
    } finally {
      isDeleteLoading.value = false;
    }
  }

  void clear() => colorName.clear();

  @override
  void onClose() {
    colorName.dispose();
    super.onClose();
  }
}
