import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/common_padding.dart';

import '../../../common_widget/colors.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';

class QuickActionComponent extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bagGroundColor;
  final Color contentColor;
  final VoidCallback onTap;

  const QuickActionComponent({
    super.key,
    required this.label,
    required this.icon,
    this.bagGroundColor = AppColors.blackColor,
    this.contentColor = AppColors.whiteColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 70.h,
          padding: SymmetricPadding(horizontal: 10).getPadding(),
          margin: SymmetricPadding(horizontal: 5).getPadding(),
          decoration: BoxDecoration(
            color: bagGroundColor,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [BoxShadow(blurRadius: 2, color: AppColors.greyColor)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30.sp, color: contentColor),
              setHeight(height: 5),
              Text(
                label,
                style: CustomTextStyle.customNato(
                  color: contentColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
