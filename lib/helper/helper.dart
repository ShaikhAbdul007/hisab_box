import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/textstyle.dart';

import '../common_widget/colors.dart';

void showMessage({required String message, int seconds = 1}) {
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      duration: Duration(seconds: seconds),
      content: Text(
        message,
        style: CustomTextStyle.customRaleway(color: AppColors.whiteColor),
      ),
    ),
  );
}

void showSnackBar({required String error}) {
  Get.snackbar(
    'Error',
    error,
    snackPosition: SnackPosition.TOP,
    backgroundColor: AppColors.buttonRedColor,
    colorText: AppColors.whiteColor,
  );
}

void unfocus() {
  FocusManager.instance.primaryFocus?.unfocus();
}
