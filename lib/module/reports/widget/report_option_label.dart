import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/module/reports/controller/report_controller.dart';
import '../../../common_widget/common_padding.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';

class ReportOptionContainerLabel extends StatelessWidget {
  final ReportController controller;
  const ReportOptionContainerLabel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.daysOtionLabel.length,
        itemBuilder: (context, index) {
          var label = controller.daysOtionLabel[index];
          return Obx(
            () => InkWell(
              onTap: () {
                controller.reportLabels.value = label;
              },
              child: Container(
                padding: SymmetricPadding(horizontal: 5).getPadding(),
                margin: SymmetricPadding(horizontal: 5).getPadding(),
                decoration: BoxDecoration(
                  color:
                      controller.reportLabels.value == label
                          ? AppColors.blackColor
                          : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 18.sp,
                      color:
                          controller.reportLabels.value == label
                              ? AppColors.whiteColor
                              : AppColors.blackColor,
                    ),
                    setWidth(width: 5),
                    Text(
                      label,
                      style: CustomTextStyle.customMontserrat(
                        fontSize: 14,

                        color:
                            controller.reportLabels.value == label
                                ? AppColors.whiteColor
                                : AppColors.blackColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
