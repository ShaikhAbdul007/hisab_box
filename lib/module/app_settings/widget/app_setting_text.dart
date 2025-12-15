import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';

class AppSettingText extends StatelessWidget {
  final Widget child;

  const AppSettingText({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      paddingOption: SymmetricPadding(horizontal: 18),
      child: Container(
        padding: SymmetricPadding(horizontal: 5).getPadding(),
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: AppColors.whiteColor,
        ),
        child: child,
      ),
    );
  }
}
