import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import '../../../common_widget/colors.dart';
import '../../../helper/set_format_date.dart';
import '../../../helper/textstyle.dart';
import '../../inventory/model/product_model.dart';

class SellingConfirmationListText extends StatelessWidget {
  final ProductModel inventoryModel;
  final void Function()? plusOnTap;
  final void Function()? minusOnTap;
  final void Function()? removeOnTap;
  final Widget sellingPrices;
  final TextEditingController dicountController;
  final void Function(String)? onDiscountChanged;
  const SellingConfirmationListText({
    super.key,
    required this.inventoryModel,
    this.plusOnTap,
    this.minusOnTap,
    required this.sellingPrices,
    this.removeOnTap,
    required this.dicountController,
    this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      margin: SymmetricPadding(horizontal: 15, vertical: 10).getPadding(),
      padding: SymmetricPadding(horizontal: 10, vertical: 5).getPadding(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inventoryModel.name ?? '',
                    style: CustomTextStyle.customPoppin(),
                  ),
                  Text(
                    getStringLengthText(inventoryModel.barcode ?? ''),
                    style: CustomTextStyle.customRaleway(
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
              Container(
                height: 40.h,
                width: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.blackColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(child: sellingPrices),
              ),
            ],
          ),
          setHeight(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: minusOnTap,
                    child: CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppColors.greyColor,
                      child: Text(
                        '-',
                        style: CustomTextStyle.customPoppin(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  setWidth(width: 5),
                  Container(
                    height: 30.h,
                    width: 50.w,
                    decoration: BoxDecoration(
                      color: AppColors.greyColorShade100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        inventoryModel.quantity.toString(),
                        style: CustomTextStyle.customPoppin(
                          color: AppColors.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  setWidth(width: 5),
                  InkWell(
                    onTap: plusOnTap,
                    child: CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppColors.blackColor,
                      child: Text(
                        '+',
                        style: CustomTextStyle.customPoppin(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  setWidth(width: 5),
                  Container(
                    height: 40.h,
                    width: 50.w,
                    padding: EdgeInsets.zero,
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: AppColors.greyColor,
                    //     width: 0.5.w,
                    //   ),
                    //   borderRadius: BorderRadius.circular(10.r),
                    // ),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: dicountController,
                      onChanged: onDiscountChanged,
                      cursorHeight: 14.sp,
                      cursorColor: AppColors.blackColor,
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9@./&\s]'),
                        ),
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        contentPadding:
                            OnlyPadding(left: 10, bottom: 15).getPadding(),
                        border: InputBorder.none,
                        label: Text('%', style: CustomTextStyle.customPoppin()),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 0.5.w),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.greyColor),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 0.5.w),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        labelStyle: CustomTextStyle.customMontserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: removeOnTap,
                child: Container(
                  height: 30.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: AppColors.redColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Remove',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
