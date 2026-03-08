import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import 'package:inventory/supabase_db/storage_service.dart';
import '../../setting/model/user_model.dart';

class UserProfileController extends GetxController with CacheManager {
  // 🟢 Observables
  RxBool isLoading = false.obs;
  RxBool readOnly = true.obs;
  RxBool isDataLoading = false.obs;
  Rx<File?> profileImage = Rx<File?>(null);
  RxString profileImageUrl = ''.obs;

  final userId = SupabaseConfig.auth.currentUser?.id;
  final ImagePicker _picker = ImagePicker();

  // 🟢 Text Controllers
  final emailController = TextEditingController();
  final shopNameController = TextEditingController();
  final mobileController = TextEditingController();
  final alternativeMobileController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  final stateController = TextEditingController();

  @override
  void onInit() {
    setUserDetails();
    super.onInit();
  }

  // 📸 Image Pick Logic (Directly use picked file)
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (image != null) {
        profileImage.value = File(image.path);
        profileImageUrl.value = ''; // Local file selected, clear network URL
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // ---------------- UPDATE PROFILE (SUPABASE) ----------------
  Future<void> updateUserDetails() async {
    if (userId == null) return;

    isLoading.value = true;
    unfocus();

    try {
      String finalImageUrl = profileImageUrl.value;

      // 1️⃣ Check if a new local image was picked to upload
      if (profileImage.value?.path != null &&
          profileImage.value!.path.isNotEmpty) {
        finalImageUrl = await StorageService.uploadProfileImage(
          file: profileImage.value!,
          userId: userId!,
        );
      }

      final String formatCreatedAt = setFormateDate();
      final String updatedDateTimeAt = formatDateForDB(formatCreatedAt);

      final updatedData = {
        "name": shopNameController.text.trim(),
        "email": emailController.text.trim(),
        "address": addressController.text.trim(),
        "city": cityController.text.trim(),
        "pincode": pincodeController.text.trim(),
        "state": stateController.text.trim(),
        "mobile_no": mobileController.text.trim(),
        "alternate_mobile_no": alternativeMobileController.text.trim(),
        "updated_at": updatedDateTimeAt,
        "profile_image": finalImageUrl,
      };

      // 2️⃣ Supabase Update
      await SupabaseConfig.from('users').update(updatedData).eq('id', userId!);

      // 3️⃣ Update Local Cache
      final updatedUser = UserModel(
        name: shopNameController.text.trim(),
        email: emailController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        pincode: pincodeController.text.trim(),
        state: stateController.text.trim(),
        mobileNo: mobileController.text.trim(),
        alternateMobileNo: alternativeMobileController.text.trim(),
        image: finalImageUrl,
        isSaved: true,
      );

      saveUserData(updatedUser);
      _setProfileSource(finalImageUrl); // Refresh UI state

      readOnly.value = true;
      showMessage(message: "Profile Updated Successfully ✅");
    } catch (e) {
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- LOAD USER DATA ----------------
  void setUserDetails() async {
    isDataLoading.value = true;
    try {
      final cachedUser = retrieveUserDetail();

      // UI fill from Cache
      _fillControllers(cachedUser);
      _setProfileSource(cachedUser.image);

      // Agar Cache empty hai ya image link missing hai, toh DB se fetch karo
      if (userId != null &&
          (cachedUser.isSaved != true || (cachedUser.image ?? '').isEmpty)) {
        final response =
            await SupabaseConfig.from(
              'users',
            ).select().eq('id', userId!).maybeSingle();

        if (response != null) {
          final userRes = UserModel.fromJson(response);
          _fillControllers(userRes);
          _setProfileSource(userRes.image);
          saveUserData(userRes);
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      isDataLoading.value = false;
    }
  }

  // Helper to set image source state
  void _setProfileSource(String? imageValue) {
    final value = (imageValue ?? '').trim();
    debugPrint("Setting Image Source: $value"); // Debugging ke liye

    if (StorageService.isNetworkImage(value)) {
      profileImageUrl.value = value;
      profileImage.value = null;
    } else if (value.isNotEmpty && File(value).existsSync()) {
      profileImage.value = File(value);
      profileImageUrl.value = '';
    } else {
      profileImage.value = null;
      profileImageUrl.value = '';
    }
  }

  // void setprofileParamet() {
  //   final profile = profileImage.value;
  //   final profileUrl = profileImageUrl.value.trim();
  //   final canShowImage = profile != null && profile.existsSync();
  // }

  // Helper to fill controllers
  void _fillControllers(UserModel user) {
    shopNameController.text = user.name ?? '';
    mobileController.text = user.mobileNo ?? '';
    alternativeMobileController.text = user.alternateMobileNo ?? '';
    pincodeController.text = user.pincode ?? '';
    stateController.text = user.state ?? '';
    addressController.text = user.address ?? '';
    cityController.text = user.city ?? '';
    emailController.text = user.email ?? '';
  }

  @override
  void onClose() {
    emailController.dispose();
    shopNameController.dispose();
    mobileController.dispose();
    alternativeMobileController.dispose();
    addressController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    stateController.dispose();
    super.onClose();
  }
}
