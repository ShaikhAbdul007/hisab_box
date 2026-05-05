import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/auth/login/repo/login_repo.dart';
import 'package:inventory/module/user_profile/repo/user_repo.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/helper.dart';
import '../../../../routes/route_name.dart';
import '../../../../routes/routes.dart';

class LoginController extends GetxController with CacheManager {
  LoginRepo loginRepo = LoginRepo();
  UserProfileRepo userProfileRepo = UserProfileRepo();
  final email = TextEditingController();
  final password = TextEditingController();
  RxBool loginLoading = false.obs;
  RxBool verifyLoading = false.obs;
  RxBool obscureTextValue = true.obs;
  RxString otp = ''.obs;

  // ── Resend OTP timer ──────────────────────────────────────────────────────
  RxInt resendSeconds = 30.obs;
  RxBool canResend = false.obs;

  void startResendTimer() {
    resendSeconds.value = 180;
    canResend.value = false;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      resendSeconds.value--;
      if (resendSeconds.value <= 0) {
        canResend.value = true;
        return false;
      }
      return true;
    });
  }

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

        // ── Fetch & cache full user profile (includes shopType) ──────
        // HomeController.setShopType() reads from cache on onInit,
        // so we must populate it before navigating.
        try {
          final userResponse = await userProfileRepo.getUserDetails();
          if (userResponse.success == success) {
            saveUserData(userResponse);
            AppLogger.info(
              'User profile cached: shopType=${userResponse.data?.shopType}',
            );
          }
        } catch (e) {
          AppLogger.info('Profile fetch failed (non-fatal): $e');
        }

        showSnackBar(
          error: response.msg ?? somethingWentMessage,
          isError: false,
        );
        AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
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
      verifyLoading.value = false;
    }
  }
}
