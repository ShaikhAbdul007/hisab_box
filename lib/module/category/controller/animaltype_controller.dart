import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/module/category/repo/animal_category_repo.dart';
import 'package:inventory/helper/app_message.dart';

class AnimalTypeController extends GetxController with CacheManager {
  AnimalCategoryRepo animalCategoryRepo = AnimalCategoryRepo();
  TextEditingController animalCategory = TextEditingController();
  final ScrollController scrollController = ScrollController();
  RxBool isSaveLoading = false.obs;
  RxBool isDeleteAnimalCategory = false.obs;
  RxBool isFetchAnimalCategory = false.obs;
  RxBool isLoadingMore = false.obs;
  RxString shopType = ''.obs;
  RxList<CategoryModelListData> animalTypeList = <CategoryModelListData>[].obs;
  var data = Get.arguments;
  int _page = 1;
  int _totalPages = 1;
  bool get hasMore => _page < _totalPages;

  ShopType get shopTypeEnum => ShopType.fromString(shopType.value);

  @override
  void onInit() {
    setShopType();
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
        showSnackBar(
          error: shopTypeEnum.config.categoryAddSuccess,
          isError: false,
        );
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
    _page = 1;
    animalTypeList.clear();
    isFetchAnimalCategory.value = true;
    try {
      var response = await animalCategoryRepo.getAnimalCategory(page: _page);
      if (response.success == success) {
        animalTypeList.value = response.categorymodeldata?.data ?? [];
        _totalPages = response.categorymodeldata?.pagination?.totalPages ?? 1;
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

  Future<void> _loadMore() async {
    _page++;
    isLoadingMore.value = true;
    try {
      final response = await animalCategoryRepo.getAnimalCategory(page: _page);
      if (response.success == success) {
        animalTypeList.addAll(response.categorymodeldata?.data ?? []);
        _totalPages =
            response.categorymodeldata?.pagination?.totalPages ?? _totalPages;
        saveAnimalList(animalTypeList);
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

  Future<void> deleteAnimalCategory(String animalCategoryId) async {
    isDeleteAnimalCategory.value = true;
    try {
      var response = await animalCategoryRepo.deleteAnimalCategory(
        id: animalCategoryId,
      );
      if (response.success == success) {
        showSnackBar(
          error: shopTypeEnum.config.categoryDeleteSuccess,
          isError: false,
        );
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

  @override
  void onClose() {
    animalCategory.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
