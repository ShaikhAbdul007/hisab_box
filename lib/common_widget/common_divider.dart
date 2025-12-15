import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';

class CommonDivider extends StatelessWidget {
  final double indent;
  final double endIndent;
  final double height;
  final double thickness;
  final Color? color;

  const CommonDivider({
    super.key,
    this.indent = 0,
    this.endIndent = 0,
    this.height = 0.5,
    this.thickness = 0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      indent: indent.sp,
      endIndent: endIndent.sp,
      height: height.h,
      thickness: thickness.sp,
      color: color ?? AppColors.blackColor,
    );
  }
}
