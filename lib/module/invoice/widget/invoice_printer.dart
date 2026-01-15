import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/sell/model/print_model.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';

import '../../../common_widget/common_divider.dart';

class InvoicePrinterView extends StatelessWidget with CacheManager {
  final List<SellItem> scannedProductDetails;
  final PrintInvoiceModel printInvoiceModel;
  final String paymentMethod;
  final void Function(ReceiptController) onInitialized;
  InvoicePrinterView({
    super.key,
    required this.scannedProductDetails,
    required this.onInitialized,
    required this.paymentMethod,
    required this.printInvoiceModel,
  });

  @override
  Widget build(BuildContext context) {
    var user = retrieveUserDetail();
    var bankDetails = retrieveBankModelDetail();

    String userName =
        user.name?.isNotEmpty ?? false ? user.name!.substring(0, 1) : "HB";
    double total = 0;
    double savedAmount = 0;
    int discountPercentage = 0;
    return Receipt(
      backgroundColor: AppColors.whiteColor,
      builder:
          (context) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    user.image == null || user.image!.isEmpty
                        ? CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.blackColor,
                          child: Text(
                            userName,
                            style: CustomTextStyle.customMontserrat(
                              color: AppColors.whiteColor,
                              fontSize: 40,
                            ),
                          ),
                        )
                        : CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.blackColor,
                          backgroundImage:
                              user.image == null || user.image!.isEmpty
                                  ? null
                                  : FileImage(File(user.image ?? '')),
                          child: Text(''),
                        ),
                    setWidth(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.name}',
                          style: CustomTextStyle.customMontserrat(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        setHeight(height: 8),
                        if (user.alternateMobileNo?.isNotEmpty ?? false) ...{
                          Text(
                            '${user.mobileNo}/${user.alternateMobileNo}',
                            style: CustomTextStyle.customMontserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        } else ...{
                          Text(
                            '${user.mobileNo}',
                            style: CustomTextStyle.customMontserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        },
                      ],
                    ),
                  ],
                ),
                setHeight(height: 10),
                CommonDivider(endIndent: 0, indent: 0),
                setHeight(height: 10),
                Flexible(
                  child: Text(
                    "${user.address},${user.city},${user.pincode}",
                    style: CustomTextStyle.customMontserrat(
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                setHeight(height: 20),
                CommonDivider(endIndent: 0, indent: 0),
                setHeight(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bill No',
                        style: CustomTextStyle.customMontserrat(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${printInvoiceModel.billNo}',
                        style: CustomTextStyle.customMontserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                setHeight(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Date',
                        style: CustomTextStyle.customMontserrat(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        printInvoiceModel.soldAt ?? '',
                        style: CustomTextStyle.customMontserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                setHeight(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Time',
                        style: CustomTextStyle.customMontserrat(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        printInvoiceModel.time ?? '',
                        style: CustomTextStyle.customMontserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                setHeight(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Payment Method',
                        style: CustomTextStyle.customMontserrat(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        paymentMethod,
                        style: CustomTextStyle.customMontserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                setHeight(height: 10),
                const CommonDivider(color: AppColors.blackColor),
                setHeight(height: 10),
                ...scannedProductDetails.map((item) {
                  discountPercentage = item.discount ?? 0;
                  total += (item.finalPrice ?? 0);
                  savedAmount +=
                      ((item.originalPrice ?? 0) * (item.quantity ?? 1)) -
                      (item.finalPrice ?? 0);

                  return CustomPadding(
                    paddingOption: OnlyPadding(bottom: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name ?? "No Name",
                                style: CustomTextStyle.customMontserrat(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24,
                                ),
                              ),
                              if (item.flavours!.isNotEmpty) ...{
                                setHeight(height: 5),
                                Text(
                                  item.flavours ?? "",
                                  style: CustomTextStyle.customMontserrat(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              },
                              setHeight(height: 5),
                              RichText(
                                text: TextSpan(
                                  text:
                                      "${item.quantity} x ${item.originalPrice}",
                                  style: CustomTextStyle.customMontserrat(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                  children:
                                      item.discount! > 0
                                          ? [
                                            TextSpan(
                                              text: " @ ",
                                              style:
                                                  CustomTextStyle.customMontserrat(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15,
                                                  ),
                                            ),
                                            TextSpan(
                                              text: "${item.discount} %",
                                              style:
                                                  CustomTextStyle.customMontserrat(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                  ),
                                            ),
                                          ]
                                          : [],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "₹ ${item.finalPrice}",
                            textAlign: TextAlign.right,
                            style: CustomTextStyle.customMontserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const CommonDivider(color: AppColors.blackColor),

                setHeight(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        "Grand Total",
                        style: CustomTextStyle.customMontserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "₹ $total",
                        textAlign: TextAlign.right,
                        style: CustomTextStyle.customPoppin(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                setHeight(height: 10),
                const CommonDivider(color: AppColors.blackColor),
                setHeight(height: 20),
                Column(
                  children: [
                    setHeight(height: 20),
                    discountPercentage > 0
                        ? Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: CustomTextStyle.customNato(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackColor,
                              ),
                              children: [
                                const TextSpan(text: "★ You saved "),
                                TextSpan(
                                  text: "₹ ${savedAmount.toStringAsFixed(2)}",
                                  style: CustomTextStyle.customNato(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                                const TextSpan(text: " on this order ★"),
                              ],
                            ),
                          ),
                        )
                        : Center(
                          child: Text(
                            "★ Add more items to unlock exciting discounts! ★",
                            textAlign: TextAlign.center,
                            style: CustomTextStyle.customPoppin(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                    setHeight(height: 25),
                    Center(
                      child: Text(
                        "✔ Keep shopping to save more !",
                        style: CustomTextStyle.customPoppin(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    setHeight(height: 25),
                    Center(
                      child: Text(
                        "Visit again !",
                        style: CustomTextStyle.customPoppin(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),
                setHeight(height: 30),
                bankDetails.upiId != null &&
                        paymentMethod.toLowerCase() != 'cash'
                    ? CustomPadding(
                      paddingOption: SymmetricPadding(horizontal: 80),
                      child: Column(
                        children: [
                          UPIPaymentQRCode(
                            upiDetails: UPIDetails(
                              upiID: bankDetails.upiId ?? '',
                              payeeName: bankDetails.accountName ?? '',
                              amount: total,
                            ),
                            size: 200,
                            embeddedImageSize: const Size(60, 60),
                            loader: CommonProgressbar(
                              color: AppColors.blackColor,
                            ),
                          ),
                          setHeight(height: 15),
                          Text(
                            '₹ $total /-',
                            style: CustomTextStyle.customPoppin(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                        ],
                      ),
                    )
                    : Container(),
                setHeight(height: 150),
              ],
            ),
          ),
      onInitialized: (controller) {
        onInitialized(controller);
      },
    );
  }
}

class BarcodePrinterView extends StatelessWidget with CacheManager {
  final void Function(ReceiptController) onInitialized;
  final dynamic data;

  BarcodePrinterView({super.key, required this.onInitialized, this.data});

  @override
  Widget build(BuildContext context) {
    var user = retrieveUserDetail();
    return Receipt(
      defaultTextStyle: TextStyle(fontSize: 20),
      builder: (context) {
        return SizedBox(
          height: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.name ?? "",
                style: CustomTextStyle.customMontserrat(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              setHeight(height: 3),
              Text(
                "Flr:${data.flavor}",
                style: CustomTextStyle.customMontserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              setHeight(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Wt:${data.weight}",
                    style: CustomTextStyle.customMontserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  setWidth(width: 10),
                  Text(
                    "MRP: ₹${data.sellingPrice}",
                    style: CustomTextStyle.customMontserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              setHeight(height: 3),
              BarcodeWidget(
                barcode: Barcode.ean13(),
                data: data.barcode,
                height: 60,
                width: 300,
                drawText: true,
              ),
            ],
          ),
        );
      },
      onInitialized: onInitialized,
    );
  }
}

class BarcodeRichText extends StatelessWidget {
  final String label;
  final String labelValue;
  const BarcodeRichText({
    super.key,
    required this.label,
    required this.labelValue,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: '$label : ',
        style: CustomTextStyle.customMontserrat(fontSize: 15),
        children: [
          TextSpan(
            text: labelValue,
            style: CustomTextStyle.customMontserrat(fontSize: 20),
          ),
        ],
      ),
    );
  }
}


 // if (discountPercentage != 0.0) ...{
                //   Row(
                //     children: [
                //       Expanded(
                //         flex: 4,
                //         child: Text(
                //           "Discount",
                //           style: CustomTextStyle.customMontserrat(
                //             fontWeight: FontWeight.w500,
                //             fontSize: 18,
                //           ),
                //         ),
                //       ),
                //       const Expanded(child: SizedBox()),
                //       Expanded(
                //         flex: 3,
                //         child: Text(
                //           '₹ $discountPercentage',
                //           textAlign: TextAlign.right,
                //           style: CustomTextStyle.customMontserrat(
                //             fontWeight: FontWeight.bold,
                //             fontSize: 20,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                //   setHeight(height: 10),
                // },