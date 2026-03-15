import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/push_notification/local_notification_service.dart';
import 'package:inventory/routes/routes.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import 'package:inventory/supabase_db/storage_service.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/helper.dart';
import '../../../../routes/route_name.dart';
import '../../../setting/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupController extends GetxController with CacheManager {
  // Text Controllers (Finalized for memory efficiency)
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmpassword = TextEditingController();
  final name = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final pincode = TextEditingController();
  final state = TextEditingController();
  final mobileNo = TextEditingController();
  final alternateMobileNo = TextEditingController();
  final shopType = TextEditingController();

  // Observables
  RxBool signUpLoading = false.obs;
  RxBool obscureTextValue = true.obs;
  RxBool isShopDetailFilled = false.obs;
  Rx<File?> profileImage = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  // Getters/Setters
  void togglePasswordVisibility() =>
      obscureTextValue.value = !obscureTextValue.value;

  // 📸 Image Picker Logic
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Image size optimize karne ke liye
      );

      if (image != null) {
        profileImage.value = File(image.path);
        debugPrint("Image selected: ${profileImage.value?.path}");
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // ============================
  // SIGN UP LOGIC
  // ============================
  Future<void> signUpUser() async {
    // Basic validation check
    if (password.text != confirmpassword.text) {
      showMessage(message: "Passwords do not match");
      return;
    }

    unfocus();
    signUpLoading.value = true;

    try {
      // 1️⃣ AUTH SIGNUP
      final AuthResponse authRes = await SupabaseConfig.auth.signUp(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final user = authRes.user;
      if (user == null) throw Exception('Auth Signup failed');

      final String userId = user.id;
      String profileImageUrl = '';

      // Get Device FCM Token from your service
      String fcmToken = await NotificationServices.getDeviceToken();
      // 2️⃣ STORAGE UPLOAD (If image selected)
      if (profileImage.value != null && profileImage.value!.existsSync()) {
        // StorageService hamesha Public URL return karega
        profileImageUrl = await StorageService.uploadProfileImage(
          file: profileImage.value!,
          userId: userId,
        );
      }

      // 3️⃣ INSERT USER PROFILE (DATABASE)
      await SupabaseConfig.from('users').insert({
        'id': userId,
        'parent_id': userId,
        'name': name.text.trim(),
        'email': email.text.trim(),
        'mobile_no': mobileNo.text.trim(),
        'alternate_mobile_no': alternateMobileNo.text.trim(),
        'address': address.text.trim(),
        'city': city.text.trim(),
        'state': state.text.trim(),
        'pincode': pincode.text.trim(),
        'shop_type': shopType.text.trim(),
        'profile_image': profileImageUrl, // S3 Link saved here
        'fcm_token': fcmToken,
      });

      // 4️⃣ CACHE USER DATA (LOCAL)
      final newUserModel = UserModel(
        name: name.text.trim(),
        email: email.text.trim(),
        address: address.text.trim(),
        city: city.text.trim(),
        pincode: pincode.text.trim(),
        state: state.text.trim(),
        mobileNo: mobileNo.text.trim(),
        shoptype: shopType.text.trim(),
        alternateMobileNo: alternateMobileNo.text.trim(),
        image: profileImageUrl,
        isSaved: true,
        fcmToken: fcmToken,
        id: userId,
        parentId: userId,
      );

      saveUserData(newUserModel);

      // Success Navigation
      showMessage(message: singUpSuccessFul);
      AppRoutes.navigateRoutes(routeName: AppRouteName.login);
    } catch (e) {
      debugPrint("🚨 Signup Error: $e");
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      signUpLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    email.dispose();
    password.dispose();
    confirmpassword.dispose();
    name.dispose();
    address.dispose();
    city.dispose();
    pincode.dispose();
    state.dispose();
    mobileNo.dispose();
    alternateMobileNo.dispose();
    shopType.dispose();
    super.onClose();
  }
}
