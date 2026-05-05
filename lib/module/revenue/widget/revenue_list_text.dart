import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/home/model/dashboard_model.dart';
import 'package:inventory/module/sell/model/sell_model.dart';

class RecentActivitiesListText extends StatelessWidget {
  final RecentActivitiesData billModel;
  const RecentActivitiesListText({super.key, required this.billModel});

  @override
  Widget build(BuildContext context) {
    final Color typeColor = _typeColor(billModel.type ?? '');

    return Container(
      margin: SymmetricPadding(horizontal: 12, vertical: 5).getPadding(),
      padding: SymmetricPadding(horizontal: 12, vertical: 10).getPadding(),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              _typeIcon(billModel.type ?? ''),
              color: typeColor,
              size: 22.sp,
            ),
          ),
          setWidth(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  billModel.referenceNo ?? '',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                setHeight(height: 3),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 11.sp,
                      color: AppColors.greyColor,
                    ),
                    setWidth(width: 3),
                    Text(
                      formatDateTime(
                        showDate: true,
                        showTime: false,
                        billModel.createdAt ?? '',
                      ),
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 6),
                    Text(
                      formatDateTime(
                        showDate: false,
                        showTime: true,
                        billModel.createdAt ?? '',
                      ),
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
                if ((billModel.description ?? '').isNotEmpty) ...[
                  setHeight(height: 4),
                  Text(
                    billModel.description!,
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 12,
                      color: AppColors.greyColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Type badge
          Container(
            padding: SymmetricPadding(horizontal: 8, vertical: 4).getPadding(),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              (billModel.type ?? '').toUpperCase(),
              style: CustomTextStyle.customOpenSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: typeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'sale':
        return Colors.green.shade600;
      case 'grn':
        return AppColors.deepPurple;
      case 'product':
        return Colors.orange;
      default:
        return AppColors.greyColor;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sale':
        return CupertinoIcons.cart_fill;
      case 'grn':
        return CupertinoIcons.arrow_down_circle_fill;
      case 'product':
        return CupertinoIcons.cube_box_fill;
      default:
        return CupertinoIcons.doc_text_fill;
    }
  }
}

class RevenueListText extends StatelessWidget {
  final SellItemData sellItemData;
  const RevenueListText({super.key, required this.sellItemData});

  @override
  Widget build(BuildContext context) {
    final String paymentMode = sellItemData.paymentType ?? '';
    final Color modeColor = _paymentColor(paymentMode);

    return Container(
      margin: SymmetricPadding(horizontal: 12, vertical: 5).getPadding(),
      padding: SymmetricPadding(horizontal: 12, vertical: 10).getPadding(),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              CupertinoIcons.cart_fill,
              color: Colors.green.shade600,
              size: 22.sp,
            ),
          ),
          setWidth(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sellItemData.billNo ?? '',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((sellItemData.customerName ?? '').isNotEmpty) ...[
                  setHeight(height: 2),
                  Text(
                    sellItemData.customerName!,
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 12,
                      color: AppColors.greyColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                setHeight(height: 3),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 11.sp,
                      color: AppColors.greyColor,
                    ),
                    setWidth(width: 3),
                    Text(
                      formatDateTime(
                        showDate: true,
                        showTime: false,
                        sellItemData.date ?? '',
                      ),
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 6),
                    Text(
                      formatDateTime(
                        showDate: false,
                        showTime: true,
                        sellItemData.date ?? '',
                      ),
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount + payment badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${sellItemData.amount ?? ''}',
                style: CustomTextStyle.customPoppin(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade600,
                ),
              ),
              setHeight(height: 6),
              if (paymentMode.isNotEmpty)
                Container(
                  padding:
                      SymmetricPadding(horizontal: 8, vertical: 3).getPadding(),
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    paymentMode.toUpperCase(),
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: modeColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _paymentColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'cash':
        return Colors.green.shade600;
      case 'card':
        return AppColors.deepPurple;
      case 'upi':
        return Colors.orange;
      case 'credit':
        return AppColors.redColor;
      default:
        return AppColors.greyColor;
    }
  }
}
