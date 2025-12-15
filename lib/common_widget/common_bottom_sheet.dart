import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_divider.dart';

import 'colors.dart';
import 'common_padding.dart';
import 'common_popup_appbar.dart';

void commonBottomSheet({
  required String label,
  required void Function() onPressed,
  required Widget child,
  bool isCancelButtonRequire = true,
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
                CustomPadding(
                  paddingOption: OnlyPadding(left: 18),
                  child: CommonPopupAppbar(
                    label: label,
                    onPressed: onPressed,
                    isCancelButtonRequire: isCancelButtonRequire,
                  ),
                ),
                CommonDivider(endIndent: 0, indent: 0),
                child,
              ],
            ),
          );
        },
      ),
    ),
  );
}
