import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/module/home/model/grid_model.dart';
import '../../../common_widget/colors.dart';
import '../../../helper/textstyle.dart';

class HomeGridContainer extends StatelessWidget {
  final CustomGridModel customGridModel;
  final bool isTextRequired;

  const HomeGridContainer({
    super.key,
    required this.customGridModel,
    this.isTextRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isTextRequired
              ? Text(
                customGridModel.label,
                style: CustomTextStyle.customNato(
                  color: AppColors.blackColor,
                  fontSize: 18,
                ),
              )
              : Icon(customGridModel.icon, color: Colors.black),

          Divider(endIndent: 30, indent: 30, color: AppColors.blackColor),
          Text(
            customGridModel.numbers.toString(),
            style: CustomTextStyle.customRaleway(
              color: AppColors.blackColor,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
