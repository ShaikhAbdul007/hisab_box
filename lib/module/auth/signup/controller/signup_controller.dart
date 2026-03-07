import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/routes/routes.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import 'package:inventory/supabase_db/storage_service.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/helper.dart';
import '../../../../routes/route_name.dart';
import '../../../setting/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupController extends GetxController with CacheManager {
  // Text controllers
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController alternateMobileNo = TextEditingController();
  TextEditingController shopType = TextEditingController();

  RxBool signUpLoading = false.obs;
  RxBool obscureTextValue = true.obs;

  RxBool isShopDetailFilled = false.obs;

  Rx<File?> profileImage = Rx<File?>(null);

  final ImagePicker picker = ImagePicker();

  String _fileExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) return 'jpg';
    return path.substring(dotIndex + 1).toLowerCase();
  }

  void setobscureTextValue() {
    obscureTextValue.value = !obscureTextValue.value;
  }

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

        debugPrint("Image saved at: ${profileImage.value?.path}");

        // 🎯 Ab database mein ye profileImage.value!.path save karna
      }
    } catch (e) {
      debugPrint("Error picking/saving image: $e");
    }
  }

  void togglePasswordVisibility() {
    obscureTextValue.value = !obscureTextValue.value;
  }

  // ============================
  // SIGN UP WITH SUPABASE
  // ============================
  Future<void> signUpUser() async {
    unfocus();
    signUpLoading.value = true;

    try {
      // 1️⃣ AUTH SIGNUP (EMAIL + PASSWORD)
      final AuthResponse authRes = await SupabaseConfig.auth.signUp(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final user = authRes.user;
      if (user == null) {
        throw Exception('Signup failed');
      }

      final String userId = user.id;
      String profileImageValue = profileImage.value?.path ?? '';

      if (profileImage.value != null && profileImage.value!.existsSync()) {
        profileImageValue = await StorageService.uploadProfileImage(
          file: profileImage.value!,
          userId: userId,
        );
      }

      // 2️⃣ INSERT USER PROFILE (BUSINESS DATA)
      await SupabaseConfig.from('users').insert({
        'id': userId,
        'name': name.text.trim(),
        'email': email.text.trim(),
        'mobile_no': mobileNo.text.trim(),
        'alternate_mobile_no': alternateMobileNo.text.trim(),
        'address': address.text.trim(),
        'city': city.text.trim(),
        'state': state.text.trim(),
        'pincode': pincode.text.trim(),
        'shop_type': shopType.text.trim(),
        'profile_image': profileImageValue,
      });

      // 3️⃣ SAVE LOCALLY (CACHE)
      saveUserData(
        UserModel(
          name: name.text,
          email: email.text,
          address: address.text,
          city: city.text,
          pincode: pincode.text,
          state: state.text,
          mobileNo: mobileNo.text,
          shoptype: shopType.text,
          alternateMobileNo: alternateMobileNo.text,
          image: profileImageValue,
          isSaved: true,
        ),
      );
      showMessage(message: singUpSuccessFul);
      AppRoutes.navigateRoutes(routeName: AppRouteName.login);
      signUpLoading.value = false;
    } catch (e) {
      signUpLoading.value = false;
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    }
  }
}
