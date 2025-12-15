import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common_widget/colors.dart';

class SettingIconContainer extends StatelessWidget {
  final IconData icon;
  const SettingIconContainer({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      width: 40.w,
      decoration: BoxDecoration(
        color: AppColors.blackColor,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Icon(icon, color: AppColors.whiteColor),
    );
  }
}
