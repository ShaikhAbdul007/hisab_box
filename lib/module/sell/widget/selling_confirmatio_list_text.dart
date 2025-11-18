import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
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
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.blackColor,
                  borderRadius: BorderRadius.circular(10),
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
                      radius: 18,
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
                    height: 30,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.greyColorShade100,
                      borderRadius: BorderRadius.circular(8),
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
                      radius: 18,
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
                    height: 40,
                    width: 80,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: AppColors.greyColorShade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: dicountController,
                      onChanged: onDiscountChanged,
                      cursorHeight: 15,
                      cursorColor: AppColors.blackColor,
                      style: CustomTextStyle.customUbuntu(
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
                        contentPadding: EdgeInsets.only(left: 10, bottom: 15),
                        border: InputBorder.none,
                        label: Text('Discount'),
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
                  height: 30,
                  width: 100,
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
          setHeight(height: 10),
        ],
      ),
    );
  }
}
