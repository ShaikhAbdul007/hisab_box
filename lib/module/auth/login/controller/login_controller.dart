import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';

import '../../../../helper/app_message.dart';
import '../../../../helper/helper.dart';
import '../../../../routes/route_name.dart';
import '../../../../routes/routes.dart';

class LoginController extends GetxController with CacheManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  RxBool loginLoading = false.obs;
  RxBool obscureTextValue = true.obs;

  void setobscureTextValue() {
    obscureTextValue.value = !obscureTextValue.value;
  }

  Future<void> loginUser() async {
    unfocus();
    loginLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      saveUserLoggedIn(true);
      showMessage(message: loginSuccessFul);
      Future.delayed(Duration(seconds: 1), () {
        loginLoading.value = false;
        AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
      });
    } on FirebaseAuthException catch (e) {
      loginLoading.value = false;
      showMessage(message: e.message ?? '');
    } catch (e) {
      loginLoading.value = false;
      showMessage(message: somethingWentMessage);
    }
  }
}
