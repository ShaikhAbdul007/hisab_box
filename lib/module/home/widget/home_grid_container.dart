import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/module/home/model/grid_model.dart';
import '../../../common_widget/colors.dart';
import '../../../helper/textstyle.dart';

class HomeGridContainer extends StatelessWidget {
  final CustomGridModel customGridModel;
  const HomeGridContainer({super.key, required this.customGridModel});

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey.shade100,
                child: Icon(
                  customGridModel.icon,
                  color: Colors.black,
                  size: 20,
                ),
              ),
              setWidth(width: 5),
              Text(
                customGridModel.label ?? '',
                style: CustomTextStyle.customNato(
                  color: AppColors.blackColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Divider(endIndent: 15, indent: 15, color: AppColors.blackColor),
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
