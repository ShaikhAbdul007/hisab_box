import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';

class CommonContainer extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  const CommonContainer({
    super.key,
    required this.child,
    this.height = 0,
    this.width = 0,
    this.radius = 10,
    this.color,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      width: width.w,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        color: color ?? AppColors.whiteColor,
      ),
      child: child,
    );
  }
}
