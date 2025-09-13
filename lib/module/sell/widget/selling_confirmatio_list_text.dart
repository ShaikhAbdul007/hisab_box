import 'package:flutter/material.dart';
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
  const SellingConfirmationListText({
    super.key,
    required this.inventoryModel,
    this.plusOnTap,
    this.minusOnTap,
    required this.sellingPrices,
    this.removeOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      backgroundColor: AppColors.blackColor,
                      child: Text(
                        '-',
                        style: CustomTextStyle.customPoppin(
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                  setWidth(width: 5),
                  Container(
                    height: 30,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.blackColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        inventoryModel.quantity.toString(),
                        style: CustomTextStyle.customPoppin(
                          color: AppColors.whiteColor,
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
