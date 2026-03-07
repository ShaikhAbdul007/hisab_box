import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../../common_widget/common_divider.dart';
import '../model/revenue_model.dart';

class RevenueListText extends StatelessWidget {
  final SellsModel billModel;
  const RevenueListText({super.key, required this.billModel});

  // String _displayTime(String? value, String? soldAt) {
  //   final raw = value ?? '';
  //   String hhmmss = '';
  //   if (raw.isNotEmpty) {
  //     hhmmss = raw.contains('.') ? raw.split('.').first : raw;
  //   } else {
  //     final fromSoldAt = soldAt ?? '';
  //     if (fromSoldAt.contains('T')) {
  //       hhmmss = fromSoldAt.split('T')[1].split('.').first;
  //     }
  //   }

  //   if (hhmmss.isEmpty) return '';
  //   final parts = hhmmss.split(':');
  //   if (parts.length < 2) return hhmmss;
  //   final int hour24 = int.tryParse(parts[0]) ?? 0;
  //   final String minute = parts[1].padLeft(2, '0');
  //   final String second = (parts.length > 2 ? parts[2] : '00').padLeft(2, '0');
  //   final String amPm = hour24 >= 12 ? 'PM' : 'AM';
  //   final int hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  //   return '${hour12.toString().padLeft(2, '0')}:$minute:$second $amPm';
  // }

  @override
  Widget build(BuildContext context) {
    double totalQty = 0;
    for (var item in billModel.items ?? []) {
      totalQty += (item.quantity ?? 0);
    }
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
                      totalQty > 0 && totalQty > 1
                          ? '${totalQty.toStringAsFixed(0)} items'
                          : '${totalQty.toStringAsFixed(0)} item',
                      style: CustomTextStyle.customMontserrat(fontSize: 17),
                    ),
                    setHeight(height: 5),
                    Row(
                      children: [
                        Text(
                          formatDate(billModel.soldAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CustomTextStyle.customPoppin(
                            color: AppColors.greyColor,
                          ),
                        ),
                        setWidth(width: 5),
                        Text(
                          formatDateTime(
                            showTime: true,
                            showDate: false,
                            billModel.time ?? '',
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
                    Text(
                      '\u{20B9} ${billModel.finalAmount}',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greenColor,
                        fontSize: 18,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: billModel.payment?.type ?? '',
                        style: CustomTextStyle.customMontserrat(
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        children: [
                          // TextSpan(
                          //   text: ' at ${revenueModel.discountPercentage}%',
                          //   style: CustomTextStyle.customUbuntu(
                          //     color: AppColors.deepPurple,
                          //   ),
                          // ),
                        ],
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
