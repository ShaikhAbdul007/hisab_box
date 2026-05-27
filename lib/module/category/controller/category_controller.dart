import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/category/repo/category_repo.dart';
import '../../../helper/app_message.dart';
import '../model/category_model.dart';

class CategoryController extends GetxController with CacheManager {
  CategoryRepo categoryRepo = CategoryRepo();
  TextEditingController category = TextEditingController();
  final ScrollController scrollController = ScrollController();
  RxBool isSaveLoading = false.obs;
  RxBool isDeleteCategory = false.obs;
  RxBool isFetchCategory = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<CategoryModelListData> categoryList = <CategoryModelListData>[].obs;
  int _page = 1;
  int _totalPages = 1;
  bool get hasMore => _page < _totalPages;

  @override
  void onInit() {
    getCategoryData();
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
    _page = 1;
    categoryList.clear();
    isFetchCategory.value = true;

    try {
      var response = await categoryRepo.getCategory(page: _page);
      if (response.success == success) {
        categoryList.value = response.categorymodeldata?.data ?? [];
        _totalPages = response.categorymodeldata?.pagination?.totalPages ?? 1;
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

  Future<void> _loadMore() async {
    _page++;
    isLoadingMore.value = true;
    try {
      final response = await categoryRepo.getCategory(page: _page);
      if (response.success == success) {
        categoryList.addAll(response.categorymodeldata?.data ?? []);
        _totalPages =
            response.categorymodeldata?.pagination?.totalPages ?? _totalPages;
        saveCategoryList(categoryList);
      } else {
        _page--;
      }
    } catch (e) {
      _page--;
      showSnackBar(error: e.toString());
    } finally {
      isLoadingMore.value = false;
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

  @override
  void onClose() {
    category.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
