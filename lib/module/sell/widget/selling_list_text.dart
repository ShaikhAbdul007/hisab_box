import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/home/model/dashboard_model.dart';
import '../../../common_widget/common_padding.dart';
import '../model/sell_model.dart';

class SellingListText extends StatelessWidget {
  final SellItemData saleModel;
  const SellingListText({super.key, required this.saleModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: SymmetricPadding(horizontal: 15, vertical: 5).getPadding(),
      child: Row(
        children: [
          Container(
            height: 80,
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
                  saleModel.quantity.toString(),
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
                Text(
                  saleModel.name ?? '',
                  style: CustomTextStyle.customPoppin(),
                ),
                Row(
                  children: [
                    Text(
                      saleModel.weight ?? '',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      saleModel.category ?? '',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      getStringLengthText(saleModel.flavor ?? ''),
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
                setHeight(height: 5),
                Row(
                  children: [
                    Text(
                      formatDateTime(saleModel.date.toString(), showDate: true),
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      formatDateTime(saleModel.date.toString(), showTime: true),
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
                setHeight(height: 5),
                Text(
                  saleModel.barcode??'',
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.greyColor,
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

class RecentActivitySellingListText extends StatelessWidget {
  final RecentActivitiesData billModel;
  const RecentActivitySellingListText({super.key, required this.billModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: SymmetricPadding(horizontal: 15, vertical: 5).getPadding(),
      child: Row(
        children: [
          Container(
            margin: SymmetricPadding(horizontal: 5).getPadding(),
            height: 70.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: AppColors.greyColorShade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5.r),
                bottomLeft: Radius.circular(5.r),
              ),
            ),
            child: Icon(CupertinoIcons.cube, size: 30.sp),
          ),
          setWidth(width: 5),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  billModel.module ?? '',
                  style: CustomTextStyle.customPoppin(fontSize: 17),
                ),
                setHeight(height: 2),
                Text(
                  billModel.type ?? '',
                  style: CustomTextStyle.customOpenSans(
                    color: AppColors.greyColor,
                  ),
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
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      formatDateTime(
                        showDate: false,
                        showTime: true,
                        billModel.createdAt ?? '',
                      ),
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
