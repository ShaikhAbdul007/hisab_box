import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/home/model/dashboard_model.dart';
import 'package:inventory/module/sell/model/sell_model.dart';
import '../../../common_widget/common_divider.dart';
import '../model/revenue_model.dart';

class RecentActivitiesListText extends StatelessWidget {
  final RecentActivitiesData billModel;
  const RecentActivitiesListText({super.key, required this.billModel});

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      paddingOption: OnlyPadding(left: 10, right: 10, bottom: 5.0),
      child: Column(
        children: [
          Row(
            children: [
              setWidth(width: 5),
              Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      billModel.module ?? '',
                      style: CustomTextStyle.customPoppin(fontSize: 17),
                    ),
                    setHeight(height: 5),
                    Row(
                      children: [
                        Text(
                          formatDateTime(
                            showDate: true,
                            showTime: false,
                            billModel.createdAt ?? '',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CustomTextStyle.customPoppin(
                            color: AppColors.greyColor,
                          ),
                        ),
                        setWidth(width: 5),
                        Text(
                          formatDateTime(
                            showDate: false,
                            showTime: true,
                            billModel.createdAt ?? '',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                    Icon(
                      CupertinoIcons.cube_box_fill,
                      size: 27,
                      color: AppColors.greyColor,
                    ),
                    RichText(
                      text: TextSpan(
                        text: billModel.type ?? '',
                        style: CustomTextStyle.customMontserrat(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        children: [],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          setHeight(height: 5),
          CommonDivider(),
        ],
      ),
    );
  }
}



class RevenueListText extends StatelessWidget {
  final SellItemData sellItemData;
  const RevenueListText({super.key, required this.sellItemData});

  @override
  Widget build(BuildContext context) {
    return CustomPadding(
      paddingOption: OnlyPadding(left: 10, right: 10, bottom: 5.0),
      child: Column(
        children: [
          Row(
            children: [
              setWidth(width: 5),
              Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellItemData.billNo ?? '',
                      style: CustomTextStyle.customPoppin(fontSize: 17),
                    ),
                    setHeight(height: 5),
                    Row(
                      children: [
                        Text(
                          formatDateTime(
                            showDate: true,
                            showTime: false,
                            sellItemData.date ?? '',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CustomTextStyle.customPoppin(
                            color: AppColors.greyColor,
                          ),
                        ),
                        setWidth(width: 5),
                        Text(
                          formatDateTime(
                            showDate: false,
                            showTime: true,
                            sellItemData.date ?? '',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                    Icon(
                      CupertinoIcons.cube_box_fill,
                      size: 27,
                      color: AppColors.greyColor,
                    ),
                    RichText(
                      text: TextSpan(
                        text: sellItemData.amount ?? '',
                        style: CustomTextStyle.customMontserrat(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        children: [],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          setHeight(height: 5),
          CommonDivider(),
        ],
      ),
    );
  }
}





