import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/module/home/model/grid_model.dart';
import '../../../common_widget/colors.dart';
import '../../../helper/textstyle.dart';

class HomeGridContainer extends StatelessWidget {
  final CustomGridModel customGridModel;
  const HomeGridContainer({super.key, required this.customGridModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 200,
      margin: OnlyPadding(right: 5, left: 5, bottom: 4).getPadding(),
      padding: OnlyPadding(right: 10, left: 10, top: 5).getPadding(),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [BoxShadow(blurRadius: 2, color: AppColors.greyColor)],
      ),
      child: Column(
        spacing: 5.sp,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customGridModel.label ?? '',
            style: CustomTextStyle.customMontserrat(
              color: AppColors.blackColor,
              fontSize: 14,
            ),
          ),
          Text(
            customGridModel.numbers.toString(),
            style: CustomTextStyle.customPoppin(
              color: AppColors.blackColor,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
