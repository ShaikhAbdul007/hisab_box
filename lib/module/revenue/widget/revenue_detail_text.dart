import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/sell/model/sell_details_model.dart';
import '../../../common_widget/common_padding.dart';

class RevenueDetailList extends StatelessWidget {
  final SellDetailsItems revenueModel;
  final String date;
  const RevenueDetailList({
    super.key,
    required this.revenueModel,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(5.r),
      ),
      margin: SymmetricPadding(horizontal: 15, vertical: 5).getPadding(),
      padding: SymmetricPadding(horizontal: 5, vertical: 4).getPadding(),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  revenueModel.productName ?? '',
                  style: CustomTextStyle.customPoppin(fontSize: 17),
                ),
                setHeight(height: 2),
                Row(
                  children: [
                    Text(
                      date,
                      style: CustomTextStyle.customOpenSans(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 5),
                    Text(
                      '\u{20B9}${revenueModel.originalPrice.toString()}',
                      style: CustomTextStyle.customOpenSans(
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
                Icon(
                  CupertinoIcons.cube_box_fill,
                  size: 27,
                  color: AppColors.greenAccentColor,
                ),
                setHeight(height: 5),
                Text(
                  '\u{20B9}${revenueModel.finalPrice}',
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.greenColor,
                    fontSize: 18,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: revenueModel.quantity.toString(),
                    style: CustomTextStyle.customOpenSans(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: ' at ${revenueModel.discountGiven}%',
                        style: CustomTextStyle.customOpenSans(
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
