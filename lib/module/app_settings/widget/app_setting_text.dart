import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';

class AppSettingText extends StatelessWidget {
  final Widget child;

  const AppSettingText({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
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
