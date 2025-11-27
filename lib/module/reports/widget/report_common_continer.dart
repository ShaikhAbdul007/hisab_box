import 'package:flutter/material.dart';

import '../../../common_widget/colors.dart';

class ReportCommonContiner extends StatelessWidget {
  final Widget child;
  const ReportCommonContiner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
