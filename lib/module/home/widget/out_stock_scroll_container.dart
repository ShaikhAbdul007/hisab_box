import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/module/inventorylist/model/inventory_model.dart';

import '../../../common_widget/colors.dart';
import '../../../common_widget/size.dart';
import '../../../helper/set_format_date.dart';
import '../../../helper/textstyle.dart';

class OutStockScrollContainer extends StatelessWidget {
  final InventoryItem product;
  const OutStockScrollContainer({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      padding: SymmetricPadding(horizontal: 5).getPadding(),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: SymmetricPadding(horizontal: 10, vertical: 5).getPadding(),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getStringLengthText(product.name ?? ''),
                style: CustomTextStyle.customPoppin(
                  color: AppColors.blackColor,
                ),
              ),
              setHeight(height: 5),
              Row(
                children: [
                  Text(
                    product.categoryName ?? '',
                    style: CustomTextStyle.customPoppin(
                      color: AppColors.blackColor,
                    ),
                  ),
                  setWidth(width: 10),
                  Text(
                    product.weight ?? '',
                    style: CustomTextStyle.customPoppin(
                      color: AppColors.blackColor,
                    ),
                  ),
                  setWidth(width: 10),
                  Text(
                    product.animalTypeName ?? '',
                    style: CustomTextStyle.customPoppin(
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
              setHeight(height: 5),
              CustomPadding(
                paddingOption: OnlyPadding(right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.flavour ?? '',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.blackColor,
                      ),
                    ),
                  ],
                ),
              ),
              setHeight(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.barcode ?? '',
                    style: CustomTextStyle.customPoppin(
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
