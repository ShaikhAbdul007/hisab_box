import 'package:flutter/material.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_padding.dart';

import '../../../common_widget/colors.dart';

class ReportCommonContiner extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  const ReportCommonContiner({
    super.key,
    required this.child,
    required this.height,
    required this.width,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      height: height,
      width: width,
      color: AppColors.whiteColor,
      margin:
          margin ?? SymmetricPadding(horizontal: 2, vertical: 5).getPadding(),
      padding:
          padding ??
          SymmetricPadding(horizontal: 10, vertical: 10).getPadding(),
      child: child,
    );
  }
}
