import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/auth/login/repo/login_repo.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/helper.dart';
import '../../../../routes/route_name.dart';
import '../../../../routes/routes.dart';

class LoginController extends GetxController with CacheManager {
  LoginRepo loginRepo = LoginRepo();
  final email = TextEditingController();
  final password = TextEditingController();
  RxBool loginLoading = false.obs;
  RxBool verifyLoading = false.obs;
  RxBool obscureTextValue = true.obs;

  void togglePasswordVisibility() {
    obscureTextValue.value = !obscureTextValue.value;
  }

  void setObscureTextValue() {
    obscureTextValue.value = !obscureTextValue.value;
  }

  Future<bool> sendOtp() async {
    unfocus();
    loginLoading.value = true;

    try {
      var body = {'email': email.text.trim()};
      var response = await loginRepo.sendOpt(body: body);
      if (response.success == success) {
        showSnackBar(
          error: response.msg ?? otpSentSuccessfully,
          isError: false,
        );
        return true;
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
        return false;
      } else {
        showSnackBar(error: somethingWentMessage);
        return false;
      }
    } catch (e) {
      showSnackBar(error: e.toString());
      return false;
    } finally {
      loginLoading.value = false;
    }
  }

  Future<bool> verifyOtp({required String otp}) async {
    unfocus();
    verifyLoading.value = true;
    try {
      var body = {'email': email.text.trim(), 'otp': otp};
      var response = await loginRepo.verifyOtp(body: body);
      if (response.success == success) {
        AppLogger.info('Login successful, token: ${response.data?.token}');
        saveToken(response.data?.token ?? '');
        saveUserLoggedIn(true);
        Future.delayed(const Duration(seconds: 1), () {
          AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
        });
        showSnackBar(error: response.msg!, isError: false);
        return true;
      } else if (response.success == failed) {
        showSnackBar(error: response.msg ?? somethingWentMessage);
        return false;
      } else {
        showSnackBar(error: somethingWentMessage);
        return false;
      }
    } catch (e) {
      // ✅ CENTRALIZED ERROR HANDLING
      showSnackBar(error: e.toString());
      return false;
    } finally {
      verifyLoading.value = false;
    }
  }
}
