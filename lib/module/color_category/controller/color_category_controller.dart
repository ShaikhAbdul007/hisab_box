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
  RxBool isLoadingMore = false.obs;
  RxList<CategoryModelListData> colorList = <CategoryModelListData>[].obs;

  final ScrollController scrollController = ScrollController();

  int _page = 1;
  int _totalPages = 1;
  bool get hasMore => _page < _totalPages;

  @override
  void onInit() {
    fetchColors();
    scrollController.addListener(_onScroll);
    super.onInit();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        hasMore) {
      _loadMore();
    }
  }

  /// Fresh load — page reset
  Future<void> fetchColors() async {
    _page = 1;
    colorList.clear();
    isFetchLoading.value = true;
    try {
      final response = await colorCategoryRepo.getColorCategories(page: _page);
      if (response.success == success) {
        colorList.value = response.categorymodeldata?.data ?? [];
        _totalPages = response.categorymodeldata?.pagination?.totalPages ?? 1;
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

  /// Load next page — append
  Future<void> _loadMore() async {
    _page++;
    isLoadingMore.value = true;
    try {
      final response = await colorCategoryRepo.getColorCategories(page: _page);
      if (response.success == success) {
        colorList.addAll(response.categorymodeldata?.data ?? []);
        _totalPages =
            response.categorymodeldata?.pagination?.totalPages ?? _totalPages;
        saveColorCategoryList(colorList);
      } else {
        _page--; // revert on failure
      }
    } catch (e) {
      _page--;
      showSnackBar(error: e.toString());
    } finally {
      isLoadingMore.value = false;
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

  Future<void> deleteColor(String id) async {
    isDeleteLoading.value = true;
    try {
      final response = await colorCategoryRepo.deleteColorCategory(id: id);
      if (response.success == success) {
        showSnackBar(error: 'Color deleted successfully', isError: false);
        await fetchColors();
      } else if (response.success == failed) {
        showMessage(message: response.msg ?? somethingWentMessage);
      } else {
        showMessage(message: somethingWentMessage);
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
    scrollController.dispose();
    super.onClose();
  }
}
