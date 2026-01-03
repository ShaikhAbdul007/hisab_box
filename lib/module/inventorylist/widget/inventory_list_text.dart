import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../inventory/model/product_model.dart';

class InventroyListText extends StatelessWidget {
  final ProductModel inventoryModel;
  final void Function()? onTap;
  final bool isInventoryScanSelected;
  const InventroyListText({
    super.key,
    required this.inventoryModel,
    this.onTap,
    required this.isInventoryScanSelected,
  });

  @override
  Widget build(BuildContext context) {
    int color = int.parse(inventoryModel.color ?? '0');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(5),
          ),
          margin: SymmetricPadding(horizontal: 15, vertical: 5).getPadding(),
          child: Row(
            children: [
              Container(
                margin: SymmetricPadding(horizontal: 5).getPadding(),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                ),
                child: Icon(CupertinoIcons.cube, size: 27),
              ),
              setWidth(width: 5),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inventoryModel.name ?? '',
                        style: CustomTextStyle.customPoppin(fontSize: 17),
                      ),
                      if (inventoryModel.flavor case ('' || null)) ...{
                        Container(),
                      } else ...{
                        setHeight(height: 2),
                        Text(
                          inventoryModel.flavor ?? '',
                          style: CustomTextStyle.customOpenSans(
                            color: AppColors.greyColor,
                          ),
                        ),
                      },
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: '${inventoryModel.animalType} ',
                              style: CustomTextStyle.customOpenSans(
                                color: AppColors.greyColor,
                              ),
                              children: [
                                TextSpan(
                                  text: '${inventoryModel.weight} ',
                                  style: CustomTextStyle.customOpenSans(
                                    color: AppColors.greyColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: '${inventoryModel.category}  ',
                                  style: CustomTextStyle.customOpenSans(
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            inventoryModel.location ?? '',
                            style: CustomTextStyle.customOpenSans(
                              color: AppColors.greyColor,
                            ),
                          ),
                          setWidth(width: 10),
                          inventoryModel.isLoosed ?? false
                              ? Text(
                                'Loosed : ${inventoryModel.isLoosed}',
                                style: CustomTextStyle.customOpenSans(
                                  color: AppColors.redColor,
                                ),
                              )
                              : Container(),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            inventoryModel.purchaseDate ?? '',
                            style: CustomTextStyle.customOpenSans(
                              color: AppColors.greyColor,
                            ),
                          ),
                          Text(
                            ' - ',
                            style: CustomTextStyle.customOpenSans(
                              color: AppColors.greyColor,
                            ),
                          ),
                          Text(
                            inventoryModel.expireDate ?? '',
                            style: CustomTextStyle.customOpenSans(
                              color: AppColors.redColor,
                            ),
                          ),
                        ],
                      ),
                      setHeight(height: 5),
                      inventoryModel.quantity! > 0 &&
                                  inventoryModel.quantity! < 10 ||
                              inventoryModel.quantity! == 0
                          ? Container(
                            height: 20.h,
                            width: 150.w,
                            padding:
                                SymmetricPadding(horizontal: 5).getPadding(),
                            decoration: BoxDecoration(
                              color: getColor(),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Row(
                              spacing: 5,
                              children: [
                                Icon(
                                  Icons.info,
                                  size: 15.sp,
                                  color: AppColors.whiteColor,
                                ),
                                Expanded(
                                  child: Text(
                                    getText(),
                                    style: CustomTextStyle.customOpenSans(
                                      color: AppColors.whiteColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : SizedBox(),
                      inventoryModel.quantity! > 0 &&
                                  inventoryModel.quantity! < 10 ||
                              inventoryModel.quantity! == 0
                          ? setHeight(height: 5)
                          : SizedBox(),
                    ],
                  ),
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
                        style: CustomTextStyle.customOpenSans(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: ' in stock',
                            style: CustomTextStyle.customOpenSans(
                              color: AppColors.greyColor,
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
        ),
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



 // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     isInventoryScanSelected
                //         ? InkWell(
                //           onTap: onTap,
                //           child: Padding(
                //             padding: const EdgeInsets.only(right: 20.0),
                //             child: Icon(CupertinoIcons.square_pencil),
                //           ),
                //         )
                //         : Container(),
                //   ],
                // ),
 // Text(
                //   inventoryModel.barcode ?? '',
                //   style: CustomTextStyle.customPoppin(
                //     color: AppColors.greyColor,
                //   ),
                // ),
 // Container(
          //   height: 80,
          //   width: 70,
          //   decoration: BoxDecoration(
          //     color: Color(color),
          //     borderRadius: BorderRadius.only(
          //       topLeft: Radius.circular(5),
          //       bottomLeft: Radius.circular(5),
          //     ),
          //   ),
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Text(
          //         'Quantity',
          //         style: CustomTextStyle.customPoppin(
          //           fontSize: 12,
          //           fontWeight: FontWeight.bold,
          //           color: AppColors.whiteColor,
          //         ),
          //       ),
          //       Text(
          //         inventoryModel.quantity.toString(),
          //         style: CustomTextStyle.customPoppin(
          //           color: AppColors.whiteColor,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),