import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/capitalization_strings.dart';
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

    print(user.address);
    print(user.alternateMobileNo);
    print(user.mobileNo);
    print(user.city);
    bool isFileAvailable =
        user.image != null &&
        user.image!.isNotEmpty &&
        File(user.image!).existsSync();
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
                    user.image == null || !isFileAvailable
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
                          backgroundImage: FileImage(
                            File(user.image!),
                          ), // Ab crash nahi hoga
                          child: const Text(''),
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
                    "${user.address?.toCapitalized() ?? ''},${user.city?.toCapitalized() ?? ''},${user.pincode?.toCapitalized() ?? ''}",
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
                        'HB-${printInvoiceModel.billNo}',
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
                        paymentMethod.toCapitalized(),
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
                        "₹ ${total.toStringAsFixed(2)}",
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
      defaultTextStyle: const TextStyle(
        fontSize: 12, // Even larger default font for maximum visibility
      ),
      builder: (context) {
        return SizedBox(
          // 🔥 OPTIMIZED FOR 25mm x 50mm LABEL STICKER
          height: 200, // Reduced height for 25mm label (was 155)
          width: 189, // 50mm width in pixels (50mm ≈ 189px at 96dpi)
          child: Padding(
            padding: const EdgeInsets.only(
              right: 6,
              left: 6,
              top: 15,
              bottom: 30, // Vertical padding for perfect centering
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: data['product'].barcode,
                  height: 90,
                  width: 175,
                ),
                const SizedBox(height: 2),
                Text(
                  user.name ?? 'Hisab Box',
                  style: CustomTextStyle.customMontserrat(
                    fontSize: 20, // Even larger for maximum visibility
                    fontWeight: FontWeight.w800, // Extra bold
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 1),
                Text(
                  data['product'].name ?? '',
                  style: CustomTextStyle.customMontserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 1),
                Text(
                  '${data['product'].flavor} | ${data['product'].weight} | ₹${data['product'].sellingPrice}',
                  style: CustomTextStyle.customMontserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
