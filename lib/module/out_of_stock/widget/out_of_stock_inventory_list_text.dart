import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../inventory/model/product_model.dart';

class OutOfStockInventoryListText extends StatelessWidget {
  final ProductModel inventoryModel;
  final void Function() deleteOnTap;
  final bool isDeleteLoading;
  const OutOfStockInventoryListText({
    super.key,
    required this.inventoryModel,
    required this.deleteOnTap,
    required this.isDeleteLoading,
  });

  @override
  Widget build(BuildContext context) {
    String rack = inventoryModel.rack ?? '';
    String level = inventoryModel.level ?? '';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(5.r),
      ),
      margin: SymmetricPadding(horizontal: 15, vertical: 5).getPadding(),
      padding: SymmetricPadding(horizontal: 5, vertical: 4).getPadding(),
      child: Row(
        children: [
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
                      Text(
                        '${inventoryModel.animalType}',
                        style: CustomTextStyle.customOpenSans(
                          color: AppColors.greyColor,
                        ),
                      ),
                      if (inventoryModel.weight?.isNotEmpty ?? false) ...{
                        Text(
                          '/${inventoryModel.weight}',
                          style: CustomTextStyle.customOpenSans(
                            color: AppColors.greyColor,
                          ),
                        ),
                      },
                      Text(
                        '/${inventoryModel.category}',
                        style: CustomTextStyle.customOpenSans(
                          color: AppColors.greyColor,
                        ),
                      ),
                      Icon(CupertinoIcons.map_pin, size: 15.sp),
                      Text(
                        level.isNotEmpty && rack.isNotEmpty
                            ? '${inventoryModel.location}/$level/$rack'
                            : level.isEmpty && rack.isNotEmpty
                            ? '${inventoryModel.location}/$rack'
                            : rack.isEmpty && level.isNotEmpty
                            ? '${inventoryModel.location}/$level'
                            : '${inventoryModel.location}',
                        style: CustomTextStyle.customOpenSans(
                          color: AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        formatDate(inventoryModel.purchaseDate ?? ''),
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
                        formatDate(inventoryModel.expireDate ?? ''),
                        style: CustomTextStyle.customOpenSans(
                          color: AppColors.redColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Icon(CupertinoIcons.cube_box_fill, size: 27, color: getColor()),
                setHeight(height: 5),
                Text(
                  '\u{20B9} ${inventoryModel.sellingPrice}',
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.blackColor,
                    fontSize: 18,
                  ),
                ),
                FittedBox(
                  child: RichText(
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
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CommonButton(
                  isLoading: isDeleteLoading,
                  height: 25,
                  radius: 5,
                  bgColor: AppColors.redColor,
                  onTap: deleteOnTap,
                  label: 'Delete',
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


 // Container(
    //   decoration: BoxDecoration(
    //     color: AppColors.whiteColor,
    //     borderRadius: BorderRadius.circular(5.r),
    //   ),
    //   margin: SymmetricPadding(horizontal: 15, vertical: 5).getPadding(),
    //   child: Row(
    //     children: [
    //       Container(
    //         margin: SymmetricPadding(horizontal: 5).getPadding(),
    //         height: 40.h,
    //         width: 40.w,
    //         decoration: BoxDecoration(
    //           color: AppColors.greyColorShade100,
    //           borderRadius: BorderRadius.only(
    //             topLeft: Radius.circular(5.r),
    //             bottomLeft: Radius.circular(5.r),
    //           ),
    //         ),
    //         child: Icon(CupertinoIcons.cube),
    //       ),
    //       setWidth(width: 5),
    //       Expanded(
    //         flex: 2,
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text(
    //               inventoryModel.name ?? '',
    //               style: CustomTextStyle.customPoppin(),
    //             ),
    //             setHeight(height: 2),
    //             Text(
    //               inventoryModel.flavor ?? '',
    //               style: CustomTextStyle.customOpenSans(
    //                 color: AppColors.greyColor,
    //                 fontSize: 13,
    //               ),
    //             ),
    //             Row(
    //               children: [
    //                 RichText(
    //                   text: TextSpan(
    //                     text: '${inventoryModel.animalType} ',
    //                     style: CustomTextStyle.customOpenSans(
    //                       color: AppColors.greyColor,
    //                       fontSize: 13,
    //                     ),
    //                     children: [
    //                       TextSpan(
    //                         text: '${inventoryModel.weight} ',
    //                         style: CustomTextStyle.customOpenSans(
    //                           color: AppColors.blackColor,
    //                           fontSize: 14,
    //                           fontWeight: FontWeight.w500,
    //                         ),
    //                       ),
    //                       TextSpan(
    //                         text: '${inventoryModel.category}  ',
    //                         style: CustomTextStyle.customOpenSans(
    //                           color: AppColors.greyColor,
    //                           fontSize: 13,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 inventoryModel.isLoosed ?? false
    //                     ? Text(
    //                       'Loosed : ${inventoryModel.isLoosed}',
    //                       style: CustomTextStyle.customOpenSans(
    //                         color: AppColors.redColor,
    //                         fontSize: 13,
    //                       ),
    //                     )
    //                     : Container(),
    //               ],
    //             ),
    //             setHeight(height: 5),
    //             // inventoryModel.quantity! > 0 && inventoryModel.quantity! < 10 ||
    //             //         inventoryModel.quantity! == 0
    //             //     ? Container(
    //             //       height: 25,
    //             //       width: 130,
    //             //       padding: EdgeInsets.symmetric(horizontal: 5),
    //             //       decoration: BoxDecoration(
    //             //         color: getColor(),
    //             //         borderRadius: BorderRadius.circular(5),
    //             //       ),
    //             //       child: Row(
    //             //         spacing: 5,
    //             //         children: [
    //             //           Icon(
    //             //             Icons.info,
    //             //             size: 15,
    //             //             color: AppColors.whiteColor,
    //             //           ),
    //             //           Expanded(
    //             //             child: Text(
    //             //               getText(),
    //             //               style: CustomTextStyle.customUbuntu(
    //             //                 color: AppColors.whiteColor,
    //             //               ),
    //             //             ),
    //             //           ),
    //             //         ],
    //             //       ),
    //             //     )
    //             //     : SizedBox(),
    //             // inventoryModel.quantity! > 0 && inventoryModel.quantity! < 10 ||
    //             //         inventoryModel.quantity! == 0
    //             //     ? setHeight(height: 5)
    //             //     : SizedBox(),
    //           ],
    //         ),
    //       ),
    //       Expanded(
    //         child: Column(
    //           children: [
    //             Text(
    //               '\u{20B9} ${inventoryModel.sellingPrice}',
    //               style: CustomTextStyle.customPoppin(
    //                 color: AppColors.blackColor,
    //                 fontSize: 18,
    //               ),
    //             ),
    //             RichText(
    //               text: TextSpan(
    //                 text: inventoryModel.quantity.toString(),
    //                 style: CustomTextStyle.customOpenSans(
    //                   color: AppColors.redColor,
    //                   fontWeight: FontWeight.w600,
    //                   fontSize: 14,
    //                 ),
    //                 children: [
    //                   TextSpan(
    //                     text: ' in stock',
    //                     style: CustomTextStyle.customOpenSans(
    //                       color: AppColors.greyColor,
    //                       fontSize: 13,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );


       // inventoryModel.quantity! > 0 &&
                  //             inventoryModel.quantity! < 10 ||
                  //         inventoryModel.quantity! == 0
                  //     ? Container(
                  //       height: 20.h,
                  //       width: 150.w,
                  //       padding: SymmetricPadding(horizontal: 5).getPadding(),
                  //       decoration: BoxDecoration(
                  //         color: getColor(),
                  //         borderRadius: BorderRadius.circular(5.r),
                  //       ),
                  //       child: Row(
                  //         spacing: 5,
                  //         children: [
                  //           Icon(
                  //             Icons.info,
                  //             size: 15.sp,
                  //             color: AppColors.whiteColor,
                  //           ),
                  //           Expanded(
                  //             child: Text(
                  //               getText(),
                  //               style: CustomTextStyle.customOpenSans(
                  //                 color: AppColors.whiteColor,
                  //                 fontSize: 12,
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     )
                  //     : SizedBox(),
                  // inventoryModel.quantity! > 0 &&
                  //             inventoryModel.quantity! < 10 ||
                  //         inventoryModel.quantity! == 0
                  //     ? setHeight(height: 5)
                  //     : SizedBox(),