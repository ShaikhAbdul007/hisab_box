import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';

import '../../setting/model/user_model.dart';

class UserProfileController extends GetxController with CacheManager {
  RxBool isLoading = false.obs;
  RxBool readOnly = true.obs;
  RxBool isDataLoading = false.obs;
  final userId = SupabaseConfig.auth.currentUser?.id;
  TextEditingController emailController = TextEditingController();
  TextEditingController shopNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController alternativeMobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  Rx<File?> profileImage = Rx<File?>(null);

  @override
  void onInit() {
    setUserDetails();
    super.onInit();
  }

  // ---------------- IMAGE PICK ----------------
  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
      print(profileImage.value?.path);
    }
  }

  // ---------------- UPDATE PROFILE (SUPABASE) ----------------
  Future<void> updateUserDetails() async {
    isLoading.value = true;

    if (userId == null) {
      isLoading.value = false;
      return;
    }

    final String formatCreatedAt = setFormateDate();

    try {
      final updatedData = {
        "name": shopNameController.text.trim(),
        "email": emailController.text.trim(),
        "address": addressController.text.trim(),
        "city": cityController.text.trim(),
        "pincode": pincodeController.text.trim(),
        "state": stateController.text.trim(),
        "mobile_no": mobileController.text.trim(),
        "alternate_mobile_no": alternativeMobileController.text.trim(),
        "updated_at": formatCreatedAt,
        "profile_image": profileImage.value?.path ?? '',
      };

      // 🔥 SUPABASE UPDATE
      await SupabaseConfig.from(
        'users',
      ).update(updatedData).eq('id', userId ?? '');

      // 🔥 UPDATE CACHE DIRECTLY
      final updatedUser = UserModel(
        name: shopNameController.text,
        email: emailController.text,
        address: addressController.text,
        city: cityController.text,
        pincode: pincodeController.text,
        state: stateController.text,
        mobileNo: mobileController.text,
        alternateMobileNo: alternativeMobileController.text,
        image: profileImage.value?.path ?? '',
      );

      saveUserData(updatedUser);
      setUserDetails();

      readOnly.value = true;
      showMessage(message: "Profile Updated Successfully ✅");
    } catch (e) {
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- LOAD USER FROM CACHE ----------------
  void setUserDetails() async {
    isDataLoading.value = true;
    final user = retrieveUserDetail();
    if (user.isSaved == false) {
      isDataLoading.value = false;
      final response =
          await SupabaseConfig.from(
            'users',
          ).select().eq('id', userId ?? '').maybeSingle();
      var userRes = UserModel.fromJson(response as Map<String, dynamic>);
      shopNameController.text = userRes.name ?? '';
      mobileController.text = userRes.mobileNo ?? '';
      alternativeMobileController.text = userRes.alternateMobileNo ?? '';
      pincodeController.text = userRes.pincode ?? '';
      stateController.text = userRes.state ?? '';
      addressController.text = userRes.address ?? '';
      cityController.text = userRes.city ?? '';
      emailController.text = userRes.email ?? '';
      profileImage.value =
          userRes.image != null && userRes.image!.isNotEmpty
              ? File(userRes.image!)
              : null;
    } else {
      shopNameController.text = user.name ?? '';
      mobileController.text = user.mobileNo ?? '';
      alternativeMobileController.text = user.alternateMobileNo ?? '';
      pincodeController.text = user.pincode ?? '';
      stateController.text = user.state ?? '';
      addressController.text = user.address ?? '';
      cityController.text = user.city ?? '';
      emailController.text = user.email ?? '';
      profileImage.value =
          user.image != null && user.image!.isNotEmpty
              ? File(user.image!)
              : null;
    }
  }
}
