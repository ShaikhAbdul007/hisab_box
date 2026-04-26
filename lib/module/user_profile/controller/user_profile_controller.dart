import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/user_profile/repo/user_repo.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import 'package:inventory/supabase_db/storage_service.dart';
import '../../setting/model/user_model.dart';

class UserProfileController extends GetxController with CacheManager {
  UserProfileRepo userProfileRepo = UserProfileRepo();
  // 🟢 Observables
  RxBool isLoading = false.obs;
  RxBool readOnly = true.obs;
  RxBool isDataLoading = false.obs;
  Rx<File?> profileImage = Rx<File?>(null);
  RxString profileImageUrl = ''.obs;

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
    isLoading.value = true;
    unfocus();

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
      };
      var response = await userProfileRepo.updateUserDetails(body: updatedData);
      if (response.success == success) {
        showSnackBar(
          error: response.msg ?? updateProfileSuccessfull,
          isError: false,
        );
        saveUserData(response);
        setUserDetails();
      } else if (response.success == failed) {
      showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
      showSnackBar(error: somethingWentMessage);
      }
      readOnly.value = true;
    showSnackBar(error: "Profile Updated Successfully ✅");
    } catch (e) {
    showSnackBar(error: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- LOAD USER DATA ----------------
  void setUserDetails() async {
    isDataLoading.value = true;
    try {
      final user = retrieveUserDetail();
      if (user.data?.name != null && user.data!.name!.isNotEmpty) {
        _fillControllers(user);
      } else {
        var response = await userProfileRepo.getUserDetails();
        if (response.success == success) {
          _fillControllers(response);
        } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
        } else {
        showSnackBar(error: somethingWentMessage);
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      isDataLoading.value = false;
    }
  }

  void _fillControllers(UserModel user) {
    shopNameController.text = user.data?.name ?? '';
    mobileController.text = user.data?.mobileNo ?? '';
    alternativeMobileController.text = user.data?.alternateMobileNo ?? '';
    pincodeController.text = user.data?.pincode ?? '';
    stateController.text = user.data?.state ?? '';
    addressController.text = user.data?.address ?? '';
    cityController.text = user.data?.city ?? '';
    emailController.text = user.data?.email ?? '';
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
