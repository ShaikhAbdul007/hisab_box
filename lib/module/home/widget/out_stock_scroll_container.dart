import 'package:flutter/material.dart';
import 'package:inventory/module/inventory/model/product_model.dart';

import '../../../common_widget/colors.dart';
import '../../../common_widget/size.dart';
import '../../../helper/set_format_date.dart';
import '../../../helper/textstyle.dart';

class OutStockScrollContainer extends StatelessWidget {
  final ProductModel product;
  const OutStockScrollContainer({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    product.category ?? '',
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
                    product.animalType ?? '',
                    style: CustomTextStyle.customPoppin(
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
              setHeight(height: 5),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.flavor ?? '',
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
