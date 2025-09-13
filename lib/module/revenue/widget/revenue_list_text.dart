import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';

import '../../sell/model/sell_model.dart';

class RevenueListText extends StatelessWidget {
  final SaleModel revenueModel;
  const RevenueListText({super.key, required this.revenueModel});

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
            height: 120,
            width: 70,
            decoration: BoxDecoration(
              color: AppColors.blackColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Quantity',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                ),
                Text(
                  revenueModel.quantity.toString(),
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.whiteColor,
                  ),
                ),
              ],
            ),
          ),
          setWidth(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(revenueModel.name, style: CustomTextStyle.customPoppin()),
                setHeight(height: 5),
                Row(
                  children: [
                    Text(
                      revenueModel.weight,
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      '\u{20B9}${revenueModel.amount}',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.deepPurple,
                        fontSize: 16,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      '${revenueModel.discountPercentage}%',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.blackColor,
                        fontSize: 16,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      '\u{20B9}${revenueModel.amountAfterDiscount}',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greenColor,
                        fontSize: 16,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      getshortStringLengthText(
                        value: revenueModel.category,
                        size: 5,
                      ),
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
                setHeight(height: 5),
                Text(
                  revenueModel.flavor,
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.greyColor,
                  ),
                ),

                setHeight(height: 5),
                Text(
                  revenueModel.barcode,
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.greyColor,
                  ),
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
        ],
      ),
    );
  }
}
