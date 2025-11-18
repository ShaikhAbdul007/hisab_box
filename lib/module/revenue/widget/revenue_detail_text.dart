import 'package:flutter/cupertino.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';

import '../model/revenue_model.dart';

class RevenueDetailList extends StatelessWidget {
  final RevenueModel revenueModel;
  const RevenueDetailList({super.key, required this.revenueModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            height: 70,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.greyColorShade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
            child: Icon(CupertinoIcons.cube, size: 30),
          ),
          setWidth(width: 5),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  revenueModel.name,
                  style: CustomTextStyle.customPoppin(fontSize: 17),
                ),
                setHeight(height: 2),
                Text(
                  revenueModel.flavour,
                  style: CustomTextStyle.customUbuntu(
                    color: AppColors.greyColor,
                  ),
                ),
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: '${revenueModel.animalCategory} ',
                        style: CustomTextStyle.customUbuntu(
                          color: AppColors.greyColor,
                        ),
                        children: [
                          TextSpan(
                            text: '${revenueModel.weight} ',
                            style: CustomTextStyle.customUbuntu(
                              color: AppColors.greyColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '${revenueModel.category}  ',
                            style: CustomTextStyle.customUbuntu(
                              color: AppColors.greyColor,
                            ),
                          ),
                          TextSpan(
                            text: '\u{20B9} ${revenueModel.amount}',
                            style: CustomTextStyle.customPoppin(
                              color: AppColors.blackColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                setHeight(height: 5),
                Row(
                  children: [
                    Text(
                      revenueModel.soldAt,
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      revenueModel.time,
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '\u{20B9}${revenueModel.sellingPrice}',
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.greenColor,
                    fontSize: 18,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: revenueModel.quantity.toString(),
                    style: CustomTextStyle.customUbuntu(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: ' at ${revenueModel.discountPercentage}%',
                        style: CustomTextStyle.customUbuntu(
                          color: AppColors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
