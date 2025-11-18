import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 10),
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: bagGroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(blurRadius: 2, color: AppColors.greyColor)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: contentColor),
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
