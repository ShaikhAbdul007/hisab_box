import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../model/category_model.dart';

class AnimalTypeController extends GetxController with CacheManager {
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

  // ================================
  // 🔥 ADD ANIMAL CATEGORY (SUPABASE)
  // ================================
  Future<void> addAnimalCategory(String categoryName) async {
    final animalCategoryModel = CategoryModel(id: userId, name: categoryName);
    isSaveLoading.value = true;

    if (userId == null) {
      isSaveLoading.value = false;
      return;
    }

    try {
      await SupabaseConfig.from('animal_categories').insert({
        'user_id': animalCategoryModel.id,
        'name': animalCategoryModel.name,
      });
      showMessage(message: animalTypeCategorySaveSuccessfull);
      clear();
      Get.back();
      await fetchCategories();
    } catch (e) {
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isSaveLoading.value = false;
    }
  }

  // ================================
  // 🔥 FETCH ANIMAL CATEGORIES (SUPABASE)
  // ================================
  Future<void> fetchCategories() async {
    isFetchAnimalCategory.value = true;
    if (userId == null) {
      isFetchAnimalCategory.value = false;
      return;
    }
    try {
      final response = await SupabaseConfig.from(
        'animal_categories',
      ).select().eq('user_id', userId ?? '').order('created_at');
      animalTypeList.value =
          (response as List).map((e) => CategoryModel.fromJson(e)).toList();
      saveAnimalCategoryModel(animalTypeList);
    } catch (e) {
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isFetchAnimalCategory.value = false;
    }
  }

  // ================================
  // 🔥 DELETE ANIMAL CATEGORY (SUPABASE)
  // ================================
  Future<void> deleteAnimalCategory(String aminalCategoryId) async {
    isDeleteAnimalCategory.value = true;

    if (userId == null) {
      isDeleteAnimalCategory.value = false;
      return;
    }
    try {
      await SupabaseConfig.from(
        'animal_categories',
      ).delete().eq('id', aminalCategoryId).eq('user_id', userId ?? '');
      showMessage(message: animalcategorydeleteSuccessMessage);
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
