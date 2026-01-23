import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/helper/logger.dart';

import '../common_widget/colors.dart';

void showMessage({
  required String message,
  int seconds = 1,
  bool isActionRequired = false,
  void Function()? onPressed,
}) {
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      duration: Duration(seconds: isActionRequired ? seconds : seconds),
      action:
          isActionRequired
              ? SnackBarAction(label: 'View', onPressed: onPressed!)
              : null,
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

void customMessageOrErrorPrint({required dynamic message}) {
  AppLogger.debug(message.toString());
}
