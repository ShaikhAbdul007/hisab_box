import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../inventory/model/product_model.dart';

class OutOfStockInventoryListText extends StatelessWidget {
  final ProductModel inventoryModel;


  const OutOfStockInventoryListText({
    super.key,
    required this.inventoryModel,
    
  });

  @override
  Widget build(BuildContext context) {
    int color = int.parse(inventoryModel.color ?? '0');
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          Container(
            height: 100,
            width: 70,
            decoration: BoxDecoration(
              color: Color(color),
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
                  inventoryModel.quantity.toString(),
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
                  inventoryModel.name ?? '',
                  style: CustomTextStyle.customPoppin(),
                ),
                setHeight(height: 5),
                Row(
                  children: [
                    Text(
                      inventoryModel.category ?? '',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      inventoryModel.weight ?? '',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      inventoryModel.animalType ?? '',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      '\u{20B9} ${inventoryModel.sellingPrice}',
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.blackColor,
                        fontSize: 16,
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
                        inventoryModel.flavor ?? '',
                        style: CustomTextStyle.customPoppin(
                          color: AppColors.greyColor,
                        ),
                      ),
                      inventoryModel.isLoosed ?? false
                          ? Text(
                            'loosed : ${inventoryModel.isLoosed}',
                            style: CustomTextStyle.customPoppin(
                              color: AppColors.redColor,
                            ),
                          )
                          : Container(),
                    ],
                  ),
                ),
                setHeight(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      inventoryModel.barcode ?? '',
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
