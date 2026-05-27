import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/sell/model/sell_details_model.dart';

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
    final int qty = revenueModel.quantity ?? 0;
    final int discount = revenueModel.discountGiven ?? 0;

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
              CupertinoIcons.cube_box_fill,
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
                  revenueModel.productName ?? '',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((revenueModel.barcode ?? '').isNotEmpty) ...[
                  setHeight(height: 2),
                  Text(
                    revenueModel.barcode!,
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 11,
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
                setHeight(height: 3),
                _infoRow([
                  revenueModel.categoryName,
                  revenueModel.animalTypeName,
                  if ((revenueModel.flavour ?? '').isNotEmpty)
                    revenueModel.flavour,
                  if ((revenueModel.weight ?? '').isNotEmpty)
                    revenueModel.weight,
                  if ((revenueModel.colorName ?? '').isNotEmpty)
                    revenueModel.colorName,
                  if ((revenueModel.brand ?? '').isNotEmpty) revenueModel.brand,
                ]),
                setHeight(height: 4),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.tag,
                      size: 11.sp,
                      color: AppColors.greyColor,
                    ),
                    setWidth(width: 3),
                    Text(
                      '₹${revenueModel.originalPrice ?? ''} × $qty',
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                    if (discount > 0) ...[
                      setWidth(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.deepPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '$discount% off',
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 10,
                            color: AppColors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Final price + qty badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${revenueModel.finalPrice ?? ''}',
                style: CustomTextStyle.customPoppin(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade600,
                ),
              ),
              setHeight(height: 6),
              Container(
                padding:
                    SymmetricPadding(horizontal: 8, vertical: 3).getPadding(),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Qty: $qty',
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(List<String?> values) {
    final parts = values.where((v) => v != null && v.isNotEmpty).toList();
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(
      parts.join('  ·  '),
      style: CustomTextStyle.customOpenSans(
        fontSize: 12,
        color: AppColors.greyColor,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
