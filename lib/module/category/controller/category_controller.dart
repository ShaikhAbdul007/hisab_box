import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Mixin
import 'package:inventory/helper/helper.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';

import '../../../helper/app_message.dart';
import '../model/category_model.dart';

class CategoryController extends GetxController
    with CacheManager, LocalService {
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

  // ==========================================
  // 🔥 ADD CATEGORY (SUPABASE + HIVE SYNC)
  // ==========================================
  Future<void> addCategory(String categoryName) async {
    isSaveLoading.value = true;

    final userId = resolveUserId(isSaveLoading.value);

    try {
      final categoryModel = CategoryModel(id: userId, name: categoryName);

      // 1. Supabase mein Insert
      final response =
          await SupabaseConfig.from('categories')
              .insert({'user_id': categoryModel.id, 'name': categoryModel.name})
              .select()
              .single();

      // 2. Local Hive Update (Immediate)
      CategoryModel newCategory = CategoryModel.fromJson(response);
      categoryList.add(newCategory);
      await LocalService.saveCategories(categoryList);

      clear();
      Get.back();

      // Refresh background sync
      await fetchCategories();
      showMessage(message: categorySaveSuccessfull);
    } catch (e) {
      clear();
      Get.back();
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isSaveLoading.value = false;
    }
  }

  // ==========================================
  // 🔥 FETCH CATEGORIES (FALLBACK MECHANISM)
  // ==========================================
  Future<void> fetchCategories() async {
    isFetchCategory.value = true;

    // --- 1. HIVE FALLBACK: Pehle local data check karo ---
    var localData = LocalService.getCachedCategories();
    if (localData.isNotEmpty) {
      categoryList.value = localData;
      // Loading false nahi karenge taaki background fetch chalta rahe agar user ko dikhana ho
    }

    final userId = resolveUserId(isSaveLoading.value);

    try {
      // --- 2. SUPABASE: Fresh data fetch karo ---
      final response = await SupabaseConfig.from(
        'categories',
      ).select().eq('user_id', userId ?? '').order('created_at');

      List<CategoryModel> freshList =
          (response as List).map((e) => CategoryModel.fromJson(e)).toList();

      // --- 3. SYNC: UI aur Hive refresh karo ---
      categoryList.value = freshList;
      await LocalService.saveCategories(freshList);

      // Aapka existing cache manager call
    } catch (e) {
      // Agar Hive khali hai aur Supabase bhi fail ho gaya tabhi error dikhao
      if (categoryList.isEmpty) {
        showMessage(message: SupabaseErrorHandler.getMessage(e));
      }
    } finally {
      isFetchCategory.value = false;
    }
  }

  // ==========================================
  // 🔥 DELETE CATEGORY (SUPABASE + HIVE SYNC)
  // ==========================================
  Future<void> deleteCategory(String aminalCategoryId) async {
    isDeleteCategory.value = true;

    final userId = resolveUserId(isSaveLoading.value);

    try {
      // 1. Supabase se Delete
      await SupabaseConfig.from(
        'categories',
      ).delete().eq('id', aminalCategoryId).eq('user_id', userId ?? '');

      // 2. Local Hive Sync
      categoryList.removeWhere((element) => element.id == aminalCategoryId);
      await LocalService.saveCategories(categoryList);

      showMessage(message: categorydeleteSuccessMessage);

      // Background re-fetch
      await fetchCategories();
    } catch (e) {
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isDeleteCategory.value = false;
    }
  }

  void clear() {
    category.clear();
  }
}
