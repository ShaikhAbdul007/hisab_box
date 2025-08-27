import 'package:flutter/material.dart';
import '../../../common_widget/colors.dart';

class SettingIconContainer extends StatelessWidget {
  final IconData icon;
  const SettingIconContainer({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: AppColors.blackColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: AppColors.whiteColor, size: 20),
    );
  }
}
