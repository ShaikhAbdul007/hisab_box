import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';

import '../../../common_widget/common_padding.dart';
import '../model/revenue_model.dart';

class RevenueDetailList extends StatelessWidget {
  final SellItem revenueModel;
  const RevenueDetailList({super.key, required this.revenueModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(5.r),
      ),
      margin: SymmetricPadding(horizontal: 15, vertical: 5).getPadding(),
      child: Row(
        children: [
          setWidth(width: 5),
          Icon(CupertinoIcons.cube, size: 30.sp),
          setWidth(width: 5),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  revenueModel.name ?? '',
                  style: CustomTextStyle.customPoppin(fontSize: 17),
                ),
                setHeight(height: 2),
                Text(
                  revenueModel.barcode ?? '',
                  style: CustomTextStyle.customOpenSans(
                    color: AppColors.greyColor,
                  ),
                ),
                if (revenueModel.flavours?.isNotEmpty ?? false) ...{
                  Text(
                    revenueModel.flavours ?? '',
                    style: CustomTextStyle.customOpenSans(
                      color: AppColors.greyColor,
                    ),
                  ),
                },
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: '${revenueModel.animalType} ',
                        style: CustomTextStyle.customOpenSans(
                          color: AppColors.greyColor,
                        ),
                        children: [
                          TextSpan(
                            text: '${revenueModel.weight} ',
                            style: CustomTextStyle.customOpenSans(
                              color: AppColors.greyColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '${revenueModel.category}  ',
                            style: CustomTextStyle.customOpenSans(
                              color: AppColors.greyColor,
                            ),
                          ),
                          TextSpan(
                            text: '\u{20B9} ${revenueModel.finalPrice}',
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
                // Row(
                //   children: [
                //     Text(
                //       revenueModel.,
                //       style: CustomTextStyle.customPoppin(
                //         color: AppColors.greyColor,
                //       ),
                //     ),
                //     setWidth(width: 10),
                //     Text(
                //       revenueModel.time,
                //       style: CustomTextStyle.customPoppin(
                //         color: AppColors.greyColor,
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
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
                        text: ' at ${revenueModel.discount}%',
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
