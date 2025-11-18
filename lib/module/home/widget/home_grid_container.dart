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
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: AppColors.greyColor,
            // offset: Offset(1, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              children: [
                Text(
                  customGridModel.label ?? '',
                  style: CustomTextStyle.customNato(
                    color: AppColors.blackColor,
                    fontSize: 14,
                  ),
                ),
                setHeight(height: 5),
                Text(
                  customGridModel.numbers.toString(),
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.blackColor,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          setWidth(width: 5),
          Container(
            height: 50,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black,
            ),
            child: Icon(customGridModel.icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
