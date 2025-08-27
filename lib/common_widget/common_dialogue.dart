import 'package:flutter/material.dart';
import 'colors.dart';

commonDialogBox({required BuildContext context, required Widget child}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: child,
        ),
      );
    },
  );
}
