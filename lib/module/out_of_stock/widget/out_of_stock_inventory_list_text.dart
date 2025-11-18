import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../inventory/model/product_model.dart';

class OutOfStockInventoryListText extends StatelessWidget {
  final ProductModel inventoryModel;

  const OutOfStockInventoryListText({super.key, required this.inventoryModel});

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
            margin: EdgeInsets.symmetric(horizontal: 5),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.greyColorShade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
            child: Icon(CupertinoIcons.cube),
          ),
          setWidth(width: 5),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inventoryModel.name ?? '',
                  style: CustomTextStyle.customPoppin(),
                ),
                setHeight(height: 2),
                Text(
                  inventoryModel.flavor ?? '',
                  style: CustomTextStyle.customUbuntu(
                    color: AppColors.greyColor,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: '${inventoryModel.animalType} ',
                        style: CustomTextStyle.customUbuntu(
                          color: AppColors.greyColor,
                          fontSize: 13,
                        ),

                        children: [
                          TextSpan(
                            text: '${inventoryModel.weight} ',
                            style: CustomTextStyle.customUbuntu(
                              color: AppColors.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '${inventoryModel.category}  ',
                            style: CustomTextStyle.customUbuntu(
                              color: AppColors.greyColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    inventoryModel.isLoosed ?? false
                        ? Text(
                          'Loosed : ${inventoryModel.isLoosed}',
                          style: CustomTextStyle.customUbuntu(
                            color: AppColors.redColor,
                            fontSize: 13,
                          ),
                        )
                        : Container(),
                  ],
                ),
                setHeight(height: 5),
                // inventoryModel.quantity! > 0 && inventoryModel.quantity! < 10 ||
                //         inventoryModel.quantity! == 0
                //     ? Container(
                //       height: 25,
                //       width: 130,
                //       padding: EdgeInsets.symmetric(horizontal: 5),
                //       decoration: BoxDecoration(
                //         color: getColor(),
                //         borderRadius: BorderRadius.circular(5),
                //       ),
                //       child: Row(
                //         spacing: 5,
                //         children: [
                //           Icon(
                //             Icons.info,
                //             size: 15,
                //             color: AppColors.whiteColor,
                //           ),
                //           Expanded(
                //             child: Text(
                //               getText(),
                //               style: CustomTextStyle.customUbuntu(
                //                 color: AppColors.whiteColor,
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     )
                //     : SizedBox(),
                // inventoryModel.quantity! > 0 && inventoryModel.quantity! < 10 ||
                //         inventoryModel.quantity! == 0
                //     ? setHeight(height: 5)
                //     : SizedBox(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '\u{20B9} ${inventoryModel.sellingPrice}',
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.blackColor,
                    fontSize: 18,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: inventoryModel.quantity.toString(),
                    style: CustomTextStyle.customUbuntu(
                      color: AppColors.redColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: ' in stock',
                        style: CustomTextStyle.customUbuntu(
                          color: AppColors.greyColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getText() {
    String? text;
    if (inventoryModel.quantity! > 0 && inventoryModel.quantity! < 10) {
      text = 'Low Stock';
    } else if (inventoryModel.quantity! == 0) {
      text = 'Out of Stock';
    }
    return text ?? '';
  }

  Color getColor() {
    Color? colors;
    if (inventoryModel.quantity! > 0 && inventoryModel.quantity! < 10) {
      colors = AppColors.greyColor;
    } else if (inventoryModel.quantity! == 0) {
      colors = AppColors.redColor;
    } else {
      colors = AppColors.blackColor;
    }
    return colors;
  }
}
