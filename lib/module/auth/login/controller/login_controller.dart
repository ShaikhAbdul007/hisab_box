import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/supabase_db/supabase_client.dart';
import 'package:inventory/supabase_db/supabase_error_handler.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/helper.dart';
import '../../../../routes/route_name.dart';
import '../../../../routes/routes.dart';

class LoginController extends GetxController with CacheManager {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  RxBool loginLoading = false.obs;
  RxBool obscureTextValue = true.obs;

  void togglePasswordVisibility() {
    obscureTextValue.value = !obscureTextValue.value;
  }

  void setobscureTextValue() {
    obscureTextValue.value = !obscureTextValue.value;
  }

  Future<void> loginUser() async {
    unfocus();
    loginLoading.value = true;

    try {
      // 1️⃣ LOGIN USING SUPABASE AUTH
      final res = await SupabaseConfig.auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      if (res.user == null) {
        throw Exception('Invalid login credentials');
      }

      final userId = res.user!.id;

      // 2️⃣ CHECK USER PROFILE EXISTS
      final profile =
          await SupabaseConfig.from(
            'users',
          ).select().eq('id', userId).maybeSingle();

      if (profile == null) {
        // Orphan auth user → safety logout
        await SupabaseConfig.auth.signOut();
        throw Exception('User profile not found');
      }

      // 3️⃣ SAVE LOCAL SESSION
      saveUserLoggedIn(true);

      showMessage(message: loginSuccessFul);

      Future.delayed(const Duration(seconds: 1), () {
        AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
      });
    } catch (e) {
      // ✅ CENTRALIZED ERROR HANDLING
      showMessage(message: SupabaseErrorHandler.getMessage(e));
    } finally {
      loginLoading.value = false;
    }
  }
}

// class LoginController extends GetxController with CacheManager {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   TextEditingController email = TextEditingController();
//   TextEditingController password = TextEditingController();
//   RxBool loginLoading = false.obs;
//   RxBool obscureTextValue = true.obs;

//   Future<void> loginUser() async {
//     unfocus();
//     loginLoading.value = true;
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: email.text,
//         password: password.text,
//       );
//       saveUserLoggedIn(true);
//       showMessage(message: loginSuccessFul);
//       Future.delayed(Duration(seconds: 1), () {
//         loginLoading.value = false;
//         AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
//       });
//     } on FirebaseAuthException catch (e) {
//       loginLoading.value = false;
//       showMessage(message: e.message ?? '');
//     } catch (e) {
//       loginLoading.value = false;
//       showMessage(message: somethingWentMessage);
//     }
//   }
// }
