import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/module/auth/signup/repo/signup_repo.dart';
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
  SignupRepo signupRepo = SignupRepo();
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
    showSnackBar(error: "Passwords do not match");
      return;
    }

    unfocus();
    signUpLoading.value = true;

    try {
      String customerMobileNo =
          '${mobileNo.text.trim()}/${alternateMobileNo.text.trim()}';
      // 1️⃣ AUTH SIGNUP

      String profileImageUrl = '';

      // Get Device FCM Token from your service
      String fcmToken = await NotificationServices.getDeviceToken();
      // 2️⃣ STORAGE UPLOAD (If image selected)
      if (profileImage.value != null && profileImage.value!.existsSync()) {
        // StorageService hamesha Public URL return karega
        profileImageUrl = await StorageService.uploadProfileImage(
          file: profileImage.value!,
          userId: '',
        );
      }

      var body = {
        'name': name.text.trim(),
        'email': email.text.trim(),
        'mobile_no': customerMobileNo,
        'address': address.text.trim(),
        'city': city.text.trim(),
        'state': state.text.trim(),
        'pincode': pincode.text.trim(),
        'shop_type': shopType.text.trim(),
        "password": "",
        "role": "admin",
        "permissions": {
          "p_customer_list": true,
          "p_credit_list": true,
          "p_reconcile_credit": true,
          "p_see_today_sale": true,
          "p_see_today_sale_detail": true,
          "p_see_revenue": true,
          "p_see_received_cash": true,
          "p_see_received_credit": true,
          "p_see_received_card": true,
          "p_see_received_upi": true,
          "p_see_report": true,
          "p_add_product": true,
          "p_add_manual_product": true,
          "p_delete_product": true,
          "p_edit_product_details": true,
          "p_add_loose_product": true,
          "p_edit_loose_product_details": true,
          "p_transfer_godown_to_shop": true,
          "p_edit_godown_product_details": true,
          "p_add_user": true,
          "p_add_bank_details": true,
          "p_edit_profile": true,
        },
      };

      final response = await signupRepo.signUp(body: body);
      if (response.success == success) {
        saveUserData(response);
      showSnackBar(error: singUpSuccessFul);
        AppRoutes.navigateRoutes(routeName: AppRouteName.login);
      } else if (response.success == failed) {
      showSnackBar(error: response.msg ?? somethingWentMessage);
      } else {
      showSnackBar(error: somethingWentMessage);
      }
    } catch (e) {
      debugPrint("🚨 Signup Error: $e");
    showSnackBar(error: SupabaseErrorHandler.getMessage(e));
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
