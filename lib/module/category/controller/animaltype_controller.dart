import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/local_db/local_db_service.dart'; // 🔥 LocalService Mixin
import 'package:inventory/module/category/model/category_model.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';

class AnimalTypeController extends GetxController
    with CacheManager, LocalService {
  final userId = SupabaseConfig.auth.currentUser?.id;
  TextEditingController animalCategory = TextEditingController();

  RxBool isSaveLoading = false.obs;
  RxBool isDeleteAnimalCategory = false.obs;
  RxBool isFetchAnimalCategory = false.obs;

  RxList<CategoryModel> animalTypeList = <CategoryModel>[].obs;

  var data = Get.arguments;

  @override
  void onInit() {
    getCategoryData();
    super.onInit();
  }

  void getCategoryData() async {
    await fetchCategories();
  }

  // ==========================================
  // 🔥 ADD ANIMAL CATEGORY (SUPABASE + HIVE)
  // ==========================================
  Future<void> addAnimalCategory(String categoryName) async {
    isSaveLoading.value = true;

    if (userId == null) {
      isSaveLoading.value = false;
      return;
    }

    try {
      // 1. Supabase mein Insert
      final response =
          await SupabaseConfig.from(
            'animal_categories',
          ).insert({'user_id': userId, 'name': categoryName}).select().single();

      // 2. Local Hive Update (Immediate Sync)
      CategoryModel newCategory = CategoryModel.fromJson(response);
      animalTypeList.add(newCategory);
      await LocalService.saveAnimalCategories(animalTypeList);

      showMessage(message: animalTypeCategorySaveSuccessfull);
      clear();
      Get.back();

      // Background refresh for safety
      await fetchCategories();
    } catch (e) {
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isSaveLoading.value = false;
    }
  }

  // ==========================================
  // 🔥 FETCH ANIMAL CATEGORIES (FALLBACK FLOW)
  // ==========================================
  Future<void> fetchCategories() async {
    isFetchAnimalCategory.value = true;

    // --- 1. FALLBACK: Pehle Hive se data uthao aur dikhao ---
    var localData = LocalService.getCachedAnimalCategories();
    if (localData.isNotEmpty) {
      animalTypeList.value = localData;
      isFetchAnimalCategory.value = false; // UI ko data mil gaya
    }

    if (userId == null) {
      isFetchAnimalCategory.value = false;
      return;
    }

    try {
      // --- 2. SUPABASE: Fresh data fetch karo ---
      final response = await SupabaseConfig.from(
        'animal_categories',
      ).select().eq('user_id', userId ?? '').order('created_at');

      List<CategoryModel> freshList =
          (response as List).map((e) => CategoryModel.fromJson(e)).toList();

      // --- 3. SYNC: UI aur Hive dono update karo ---
      animalTypeList.value = freshList;
      await LocalService.saveAnimalCategories(freshList);

      // Aapka existing CacheManager method (Agar zaroorat ho)
    } catch (e) {
      // Agar Hive mein data nahi tha aur Supabase fail ho gaya tabhi error dikhao
      if (animalTypeList.isEmpty) {
        showMessage(message: SupabaseErrorHandler.getMessage(e));
      }
    } finally {
      isFetchAnimalCategory.value = false;
    }
  }

  // =============================================
  // 🔥 DELETE ANIMAL CATEGORY (SUPABASE + HIVE)
  // =============================================
  Future<void> deleteAnimalCategory(String aminalCategoryId) async {
    isDeleteAnimalCategory.value = true;

    if (userId == null) {
      isDeleteAnimalCategory.value = false;
      return;
    }
    try {
      // 1. Supabase se Delete
      await SupabaseConfig.from(
        'animal_categories',
      ).delete().eq('id', aminalCategoryId).eq('user_id', userId ?? '');

      // 2. Local Hive Update (Sync)
      animalTypeList.removeWhere((element) => element.id == aminalCategoryId);
      await LocalService.saveAnimalCategories(animalTypeList);

      showMessage(message: animalcategorydeleteSuccessMessage);

      // Background refresh
      await fetchCategories();
    } catch (e) {
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isDeleteAnimalCategory.value = false;
    }
  }

  void clear() {
    animalCategory.clear();
  }
}
