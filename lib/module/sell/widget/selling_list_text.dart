import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../revenue/model/revenue_model.dart';
import '../model/sell_model.dart';

class SellingListText extends StatelessWidget {
  final SaleModel saleModel;
  const SellingListText({super.key, required this.saleModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 70,
            decoration: BoxDecoration(
              color: AppColors.blackColor,
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
                  saleModel.quantity.toString(),
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
                Text(saleModel.name, style: CustomTextStyle.customPoppin()),
                Row(
                  children: [
                    Text(
                      saleModel.weight,
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      saleModel.category,
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      getStringLengthText(saleModel.flavor),
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
                setHeight(height: 5),
                Row(
                  children: [
                    Text(
                      saleModel.soldAt,
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      saleModel.time,
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
                setHeight(height: 5),
                Text(
                  saleModel.barcode,
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Text(
    //   '\u{20B9}${saleModel.amount}',
    //   style: CustomTextStyle.customPoppin(
    //     color: AppColors.deepPurple,
    //     fontSize: 16,
    //   ),
    // ),
    // setWidth(width: 10),
    // Text(
    //   '${saleModel.discountPercentage}%',
    //   style: CustomTextStyle.customPoppin(
    //     color: AppColors.blackColor,
    //     fontSize: 16,
    //   ),
    // ),
    // setWidth(width: 10),
    //  Text(
    //   '\u{20B9}${saleModel.amountAfterDiscount}',
    //   style: CustomTextStyle.customPoppin(
    //     color: AppColors.greenColorShade100,
    //     fontSize: 16,
    //   ),
    // ),

    //  Container(
    //   height: 80,
    //   margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
    //   decoration: BoxDecoration(
    //     color: AppColors.whiteColor,
    //     borderRadius: BorderRadius.circular(10),
    //   ),
    //   child: Row(
    //     children: [
    //       setWidth(width: 5),
    //       CommonContainer(
    //         height: 60,
    //         width: 65,
    //         radius: 10,
    //         color: AppColors.amberColorShade100,
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Text(
    //               'Quantity',
    //               style: CustomTextStyle.customUbuntu(
    //                 fontSize: 12,
    //                 fontWeight: FontWeight.w800,
    //               ),
    //             ),
    //             setHeight(height: 5),
    //             Text(
    //               saleModel.quantity.toString(),
    //               style: CustomTextStyle.customUbuntu(fontSize: 20),
    //             ),
    //           ],
    //         ),
    //       ),
    //       setWidth(width: 20),
    //       Column(
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Text(
    //             saleModel.name,
    //             style: CustomTextStyle.customPoppin(
    //               fontSize: 14,
    //               fontWeight: FontWeight.bold,
    //             ),
    //           ),
    //           setHeight(height: 5),
    //           Row(
    //             children: [
    //               Text(
    //                 saleModel.barcode,
    //                 style: CustomTextStyle.customPoppin(
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.normal,
    //                 ),
    //               ),
    //               setWidth(width: 30),
    //               Text(
    //                 saleModel.category,
    //                 style: CustomTextStyle.customPoppin(
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.normal,
    //                 ),
    //               ),
    //             ],
    //           ),
    //           setHeight(height: 5),
    //           Row(
    //             children: [
    //               Text(
    //                 saleModel.soldAt,
    //                 style: CustomTextStyle.customPoppin(
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.normal,
    //                 ),
    //               ),
    //               setWidth(width: 30),
    //               Text(
    //                 saleModel.time,
    //                 style: CustomTextStyle.customPoppin(
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.normal,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ],
    //       ),
    //       setWidth(width: 50),
    //       CommonContainer(
    //         height: 60,
    //         width: 65,
    //         radius: 8,
    //         color: AppColors.greenColorShade100,
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Text(
    //               'Price',
    //               style: CustomTextStyle.customUbuntu(
    //                 fontSize: 12,
    //                 fontWeight: FontWeight.w800,
    //               ),
    //             ),
    //             setHeight(height: 5),
    //             Text(
    //               saleModel.amount.toString(),
    //               style: CustomTextStyle.customUbuntu(fontSize: 20),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

class RecentActivitySellingListText extends StatelessWidget {
  final BillModel billModel;
  const RecentActivitySellingListText({super.key, required this.billModel});

  @override
  Widget build(BuildContext context) {
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
            height: 70,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.greyColorShade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
            child: Icon(CupertinoIcons.cube, size: 30),
          ),
          setWidth(width: 5),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  billModel.billNo ?? '',
                  style: CustomTextStyle.customPoppin(fontSize: 17),
                ),
                setHeight(height: 2),
                Text(
                  billModel.paymentMethod ?? '',
                  style: CustomTextStyle.customUbuntu(
                    color: AppColors.greyColor,
                  ),
                ),
                // Row(
                //   children: [
                //     RichText(
                //       text: TextSpan(
                //         text: '${revenueModel.animalCategory} ',
                //         style: CustomTextStyle.customUbuntu(
                //           color: AppColors.greyColor,
                //         ),
                //         children: [
                //           TextSpan(
                //             text: '${revenueModel.weight} ',
                //             style: CustomTextStyle.customUbuntu(
                //               color: AppColors.greyColor,
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //           TextSpan(
                //             text: '${revenueModel.category}  ',
                //             style: CustomTextStyle.customUbuntu(
                //               color: AppColors.greyColor,
                //             ),
                //           ),
                //           TextSpan(
                //             text: '\u{20B9} ${revenueModel.amount}',
                //             style: CustomTextStyle.customPoppin(
                //               color: AppColors.blackColor,
                //               fontSize: 16,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                setHeight(height: 5),
                Row(
                  children: [
                    Text(
                      billModel.soldAt,
                      style: CustomTextStyle.customPoppin(
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 10),
                    Text(
                      billModel.time,
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
                  '\u{20B9}${billModel.finalAmount}',
                  style: CustomTextStyle.customPoppin(
                    color: AppColors.greenColor,
                    fontSize: 18,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: billModel.paymentMethod,
                    style: CustomTextStyle.customUbuntu(
                      color: AppColors.blackColor,
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
    );

    // Text(
    //   '\u{20B9}${saleModel.amount}',
    //   style: CustomTextStyle.customPoppin(
    //     color: AppColors.deepPurple,
    //     fontSize: 16,
    //   ),
    // ),
    // setWidth(width: 10),
    // Text(
    //   '${saleModel.discountPercentage}%',
    //   style: CustomTextStyle.customPoppin(
    //     color: AppColors.blackColor,
    //     fontSize: 16,
    //   ),
    // ),
    // setWidth(width: 10),
    //  Text(
    //   '\u{20B9}${saleModel.amountAfterDiscount}',
    //   style: CustomTextStyle.customPoppin(
    //     color: AppColors.greenColorShade100,
    //     fontSize: 16,
    //   ),
    // ),

    //  Container(
    //   height: 80,
    //   margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
    //   decoration: BoxDecoration(
    //     color: AppColors.whiteColor,
    //     borderRadius: BorderRadius.circular(10),
    //   ),
    //   child: Row(
    //     children: [
    //       setWidth(width: 5),
    //       CommonContainer(
    //         height: 60,
    //         width: 65,
    //         radius: 10,
    //         color: AppColors.amberColorShade100,
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Text(
    //               'Quantity',
    //               style: CustomTextStyle.customUbuntu(
    //                 fontSize: 12,
    //                 fontWeight: FontWeight.w800,
    //               ),
    //             ),
    //             setHeight(height: 5),
    //             Text(
    //               saleModel.quantity.toString(),
    //               style: CustomTextStyle.customUbuntu(fontSize: 20),
    //             ),
    //           ],
    //         ),
    //       ),
    //       setWidth(width: 20),
    //       Column(
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Text(
    //             saleModel.name,
    //             style: CustomTextStyle.customPoppin(
    //               fontSize: 14,
    //               fontWeight: FontWeight.bold,
    //             ),
    //           ),
    //           setHeight(height: 5),
    //           Row(
    //             children: [
    //               Text(
    //                 saleModel.barcode,
    //                 style: CustomTextStyle.customPoppin(
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.normal,
    //                 ),
    //               ),
    //               setWidth(width: 30),
    //               Text(
    //                 saleModel.category,
    //                 style: CustomTextStyle.customPoppin(
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.normal,
    //                 ),
    //               ),
    //             ],
    //           ),
    //           setHeight(height: 5),
    //           Row(
    //             children: [
    //               Text(
    //                 saleModel.soldAt,
    //                 style: CustomTextStyle.customPoppin(
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.normal,
    //                 ),
    //               ),
    //               setWidth(width: 30),
    //               Text(
    //                 saleModel.time,
    //                 style: CustomTextStyle.customPoppin(
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.normal,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ],
    //       ),
    //       setWidth(width: 50),
    //       CommonContainer(
    //         height: 60,
    //         width: 65,
    //         radius: 8,
    //         color: AppColors.greenColorShade100,
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Text(
    //               'Price',
    //               style: CustomTextStyle.customUbuntu(
    //                 fontSize: 12,
    //                 fontWeight: FontWeight.w800,
    //               ),
    //             ),
    //             setHeight(height: 5),
    //             Text(
    //               saleModel.amount.toString(),
    //               style: CustomTextStyle.customUbuntu(fontSize: 20),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
