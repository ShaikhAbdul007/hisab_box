import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'colors.dart';
import 'common_popup_appbar.dart';

commonBottomSheet({
  required String label,
  required void Function() onPressed,
  required Widget child,
}) {
  Get.bottomSheet(
    backgroundColor: AppColors.whiteColor,
    enableDrag: false,
    isDismissible: false,
    PopScope(
      canPop: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonPopupAppbar(label: label, onPressed: onPressed),
                Divider(),
                child,
              ],
            ),
          );
        },
      ),
    ),
  );
}
