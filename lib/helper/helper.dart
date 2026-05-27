import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/helper/logger.dart';

import '../common_widget/colors.dart';

enum _MessageTone { success, warning, error, info }

_MessageTone _resolveMessageTone(String message) {
  final msg = message.toLowerCase();

  if (msg.contains('❌') ||
      msg.contains('error') ||
      msg.contains('failed') ||
      msg.contains('failure') ||
      msg.contains('invalid') ||
      msg.contains('unable') ||
      msg.contains('exception') ||
      msg.contains('not found') ||
      msg.contains('not authorized') ||
      msg.contains('permission denied')) {
    return _MessageTone.error;
  }

  if (msg.contains('warning') ||
      msg.contains('warn') ||
      msg.contains('out of stock') ||
      msg.contains('alert') ||
      msg.contains('caution')) {
    return _MessageTone.warning;
  }

  if (msg.contains('✅') ||
      msg.contains('success') ||
      msg.contains('successfully') ||
      msg.contains('saved') ||
      msg.contains('updated') ||
      msg.contains('deleted') ||
      msg.contains('received') ||
      msg.contains('sent') ||
      msg.contains('printed')) {
    return _MessageTone.success;
  }

  return _MessageTone.info;
}

Color _snackColorByTone(_MessageTone tone) {
  switch (tone) {
    case _MessageTone.success:
      return Colors.green;
    case _MessageTone.warning:
      return Colors.yellow.shade700;
    case _MessageTone.error:
      return Colors.red;
    case _MessageTone.info:
      return AppColors.blackColor;
  }
}

Color _snackTextColorByTone(_MessageTone tone) {
  if (tone == _MessageTone.warning) {
    return AppColors.blackColor;
  }
  return AppColors.whiteColor;
}

void showMessage({
  required String message,
  int seconds = 2,
  bool isActionRequired = false,
  void Function()? onPressed,
}) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    final context = Get.context;
    if (context == null) return;

    final tone = _resolveMessageTone(message);
    final backgroundColor = _snackColorByTone(tone);
    final textColor = _snackTextColorByTone(tone);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: isActionRequired ? seconds : seconds),
        backgroundColor: backgroundColor,
        action:
            isActionRequired
                ? SnackBarAction(
                  label: 'View',
                  textColor: textColor,
                  onPressed: onPressed!,
                )
                : null,
        content: Text(
          message,
          style: CustomTextStyle.customRaleway(color: textColor),
        ),
      ),
    );
  });
}

void showSnackBar({required String error, bool isError = true}) {
  Get.snackbar(
    isError ? 'Error' : 'Success',
    error,
    snackPosition: SnackPosition.TOP,
    backgroundColor:
        isError ? AppColors.buttonRedColor : AppColors.buttonGreenColor,
    colorText: AppColors.whiteColor,
  );
}

void unfocus() {
  FocusManager.instance.primaryFocus?.unfocus();
}

void customMessageOrErrorPrint({required dynamic message}) {
  AppLogger.debug(message.toString());
}
