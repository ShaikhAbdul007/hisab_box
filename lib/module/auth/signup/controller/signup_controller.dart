import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/routes/routes.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/helper.dart';
import '../../../../routes/route_name.dart';
import '../../../setting/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

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
            "profile_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}";
        String permanentPath = p.join(appDocDir.path, fileName);

        // 3. Image ko Cache se Permanent folder mein copy karo
        final File savedImage = await File(image.path).copy(permanentPath);

        // 4. Update state
        profileImage.value = savedImage;

        print("✅ Image Saved Permanently at: ${profileImage.value?.path}");

        // 🎯 Ab database mein ye profileImage.value!.path save karna
      }
    } catch (e) {
      print("🚨 Error picking/saving image: $e");
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
        'profile_image': profileImage.value?.path ?? '',
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
          image: profileImage.value?.path ?? '',
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



// class SignupController extends GetxController with CacheManager {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   TextEditingController email = TextEditingController();
//   TextEditingController password = TextEditingController();
//   TextEditingController confirmpassword = TextEditingController();
//   TextEditingController name = TextEditingController();
//   TextEditingController address = TextEditingController();
//   TextEditingController city = TextEditingController();
//   TextEditingController pincode = TextEditingController();
//   TextEditingController state = TextEditingController();
//   TextEditingController mobileNo = TextEditingController();
//   TextEditingController alternateMobileNo = TextEditingController();
//   TextEditingController shopType = TextEditingController();
//   RxBool signUpLoading = false.obs;
//   RxBool obscureTextValue = true.obs;
//   RxBool isShopDetailFilled = false.obs;

//   Rx<File?> profileImage = Rx<File?>(null);
//   final ImagePicker picker = ImagePicker();

//   Future pickImage() async {
//     final img = await picker.pickImage(source: ImageSource.gallery);
//     if (img != null) profileImage.value = File(img.path);
//   }

//   void setobscureTextValue() {
//     obscureTextValue.value = !obscureTextValue.value;
//   }

//   Future<void> signUpUser() async {
//     unfocus();
//     signUpLoading.value = true;
//     try {
//       UserCredential userCredential = await _auth
//           .createUserWithEmailAndPassword(
//             email: email.text,
//             password: password.text,
//           );
//       String uid = userCredential.user!.uid;
//       final String formatCreatedAt = setFormateDate();

//       await FirebaseFirestore.instance.collection('users').doc(uid).set({
//         "name": name.text,
//         "email": email.text,
//         'password': password.text,
//         'address': address.text,
//         'city': city.text,
//         'pincode': pincode.text,
//         'state': state.text,
//         'mobileNo': mobileNo.text,
//         'shoptype': shopType.text,
//         'alternateMobileNo': alternateMobileNo.text,
//         "createdAt": formatCreatedAt,
//         "profileImage":
//             profileImage.value != null ? profileImage.value!.path : '',
//       });

//       saveUserData(
//         UserModel(
//           name: name.text,
//           email: email.text,
//           password: password.text,
//           address: address.text,
//           city: city.text,
//           pincode: pincode.text,
//           state: state.text,
//           mobileNo: mobileNo.text,
//           shoptype: shopType.text,
//           alternateMobileNo: alternateMobileNo.text,
//           image: profileImage.value != null ? profileImage.value!.path : '',
//         ),
//       );
//       showMessage(message: singUpSuccessFul);
//       signUpLoading.value = false;
//       AppRoutes.navigateRoutes(routeName: AppRouteName.login);
//     } on FirebaseAuthException catch (e) {
//       signUpLoading.value = false;
//       showMessage(message: e.message ?? '');
//     } catch (e) {
//       signUpLoading.value = false;
//       showMessage(message: somethingWentMessage);
//     }
//   }
// }