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
import 'package:path_provider/path_provider.dart';
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
  RxString profileImageUrl = ''.obs;

  String _fileExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) return 'jpg';
    return path.substring(dotIndex + 1).toLowerCase();
  }

  File? _safeProfileFile(String path) {
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  bool _hasRenderableImage(String? imageValue) {
    final value = (imageValue ?? '').trim();
    if (value.isEmpty) return false;
    if (StorageService.isNetworkImage(value)) return true;
    return File(value).existsSync();
  }

  void _setProfileSource(String? imageValue) {
    final value = (imageValue ?? '').trim();
    if (StorageService.isNetworkImage(value)) {
      profileImageUrl.value = value;
      profileImage.value = null;
      return;
    }
    profileImageUrl.value = '';
    if (value.isEmpty) {
      profileImage.value = null;
      return;
    }
    profileImage.value = _safeProfileFile(value);
  }

  @override
  void onInit() {
    setUserDetails();
    super.onInit();
  }

  // ---------------- IMAGE PICK ----------------
  Future<void> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // 🎯 Performance ke liye quality thodi kam kar do
      );

      if (image != null) {
        // 1. Permanent folder ka path lo
        final Directory appDocDir = await getApplicationDocumentsDirectory();

        // 2. Ek unique file name banao (timestamp ke saath)
        String fileName =
            "profile_${DateTime.now().millisecondsSinceEpoch}.${_fileExtension(image.path)}";
        String permanentPath = '${appDocDir.path}/$fileName';

        // 3. Image ko Cache se Permanent folder mein copy karo
        final File savedImage = await File(image.path).copy(permanentPath);

        // 4. Update state
        profileImage.value = savedImage;
        profileImageUrl.value = '';
      }
    } catch (e) {
      debugPrint("Error picking/saving image: $e");
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
    final String updatedDateTimeAt = formatDateForDB(formatCreatedAt);

    try {
      String profileImageValue = profileImageUrl.value.trim();
      final selectedFile = profileImage.value;
      if (selectedFile != null && selectedFile.existsSync()) {
        profileImageValue = await StorageService.uploadProfileImage(
          file: selectedFile,
          userId: userId!,
        );
      }

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
        "profile_image": profileImageValue,
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
        image: profileImageValue,
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
    final cachedUser = retrieveUserDetail();

    // First paint from cache for fast UI.
    shopNameController.text = cachedUser.name ?? '';
    mobileController.text = cachedUser.mobileNo ?? '';
    alternativeMobileController.text = cachedUser.alternateMobileNo ?? '';
    pincodeController.text = cachedUser.pincode ?? '';
    stateController.text = cachedUser.state ?? '';
    addressController.text = cachedUser.address ?? '';
    cityController.text = cachedUser.city ?? '';
    emailController.text = cachedUser.email ?? '';
    _setProfileSource(cachedUser.image);

    // Force remote refresh when cache has no renderable image.
    if (userId != null &&
        (cachedUser.isSaved == false || !_hasRenderableImage(cachedUser.image))) {
      final response =
          await SupabaseConfig.from(
            'users',
          ).select().eq('id', userId ?? '').maybeSingle();
      if (response != null) {
        final userRes = UserModel.fromJson(response);
        shopNameController.text = userRes.name ?? '';
        mobileController.text = userRes.mobileNo ?? '';
        alternativeMobileController.text = userRes.alternateMobileNo ?? '';
        pincodeController.text = userRes.pincode ?? '';
        stateController.text = userRes.state ?? '';
        addressController.text = userRes.address ?? '';
        cityController.text = userRes.city ?? '';
        emailController.text = userRes.email ?? '';
        _setProfileSource(userRes.image);
        saveUserData(userRes);
      }
    }
    isDataLoading.value = false;
  }
}
