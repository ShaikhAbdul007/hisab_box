import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/capitalization_strings.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/invoice/model/invoice_model.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';

import '../../../common_widget/common_divider.dart';

class InvoicePrinterView extends StatelessWidget with CacheManager {
  final InvoiceData printInvoiceModel;
  final String paymentMethod;
  final void Function(ReceiptController) onInitialized;
  InvoicePrinterView({
    super.key,

    required this.onInitialized,
    required this.paymentMethod,
    required this.printInvoiceModel,
  });

  @override
  Widget build(BuildContext context) {
    var user = retrieveUserDetail();
    var bankDetails = retrieveBankModelDetail();

    String userName =
        user.data?.name?.isNotEmpty ?? false
            ? user.data!.name!.substring(0, 1)
            : "HB";

    AppLogger.info((user.data?.address).toString());

    // AppLogger.info((user.data?.image).toString());
    AppLogger.info((user.data?.alternateMobileNo).toString());
    AppLogger.info((user.data?.mobileNo).toString());
    AppLogger.info((user.data?.city).toString());

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
                    user.data?.profilepic == null ||
                            (user.data?.profilepic?.isEmpty ?? true)
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
                        : ClipOval(
                          child: SizedBox(
                            width: 100.w,
                            height: 100.h,
                            child: Image.network(
                              user.data!.profilepic!,
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppColors.blackColor,
                                    child: Text(
                                      userName,
                                      style: CustomTextStyle.customMontserrat(
                                        color: AppColors.whiteColor,
                                        fontSize: 40,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                    setWidth(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.data?.name}',
                          style: CustomTextStyle.customMontserrat(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        setHeight(height: 8),
                        if (user.data?.alternateMobileNo?.isNotEmpty ??
                            false) ...{
                          Text(
                            '${user.data?.mobileNo}/${user.data?.alternateMobileNo}',
                            style: CustomTextStyle.customMontserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        } else ...{
                          Text(
                            '${user.data?.mobileNo}',
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
                    "${user.data?.address?.toCapitalized() ?? ''},${user.data?.city?.toCapitalized() ?? ''},${user.data?.pincode?.toCapitalized() ?? ''}",
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
                        printInvoiceModel.invoiceNo ?? '',
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
                        formatDateTime(
                          printInvoiceModel.createdAt ?? '',
                          showDate: true,
                          showTime: false,
                        ),
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
                        formatDateTime(
                          printInvoiceModel.createdAt ?? '',
                          showDate: false,
                          showTime: true,
                        ),
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
                ...printInvoiceModel.items!.map((item) {
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
                                item.productName ?? "No Name",
                                style: CustomTextStyle.customMontserrat(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24,
                                ),
                              ),
                              if (item.categoryName!.isNotEmpty) ...{
                                setHeight(height: 5),
                                Text(
                                  "${item.categoryName} x ${item.animalTypeName}",
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
                                      printInvoiceModel
                                                  .orderSummary
                                                  ?.customerSaved! ==
                                              "0.0"
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
                                              text:
                                                  "${printInvoiceModel.orderSummary?.totalDiscount} %",
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
                            "₹ ${printInvoiceModel.orderSummary?.finalAmount}",
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
                        "₹ ${printInvoiceModel.orderSummary!.finalAmount}",
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
                bankDetails.data?.upiId != null &&
                        paymentMethod.toLowerCase() != 'cash'
                    ? CustomPadding(
                      paddingOption: SymmetricPadding(horizontal: 80),
                      child: Column(
                        children: [
                          UPIPaymentQRCode(
                            upiDetails: UPIDetails(
                              upiID: bankDetails.data?.upiId ?? '',
                              payeeName: bankDetails.data?.accountHolder ?? '',
                              amount: total,
                            ),
                            size: 200,
                            embeddedImageSize: const Size(60, 60),
                            loader: CommonProgressBar(
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
                // Add section — Pet Shop only
                if (ShopType.fromString(user.data?.shopType ?? '') ==
                    ShopType.petShop)
                  RichText(
                    text: TextSpan(
                      style: CustomTextStyle.customMontserrat(),
                      children: [
                        TextSpan(
                          text: '#Add.\n',
                          style: CustomTextStyle.customOpenSans(
                            color: AppColors.blackColor,
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text: 'Raah Constra\n',
                          style: CustomTextStyle.customOpenSans(
                            color: AppColors.blackColor,
                            fontSize: 20,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Water Proofing | Interior Design | False Ceiling|',
                          style: CustomTextStyle.customOpenSans(
                            color: AppColors.blackColor,
                            fontSize: 20,
                          ),
                        ),
                        TextSpan(
                          text: 'Painting | All Renovation Work.\n',
                          style: CustomTextStyle.customOpenSans(
                            color: AppColors.blackColor,
                            fontSize: 20,
                          ),
                        ),
                        TextSpan(
                          text: 'www.raahconstra.com\n',
                          style: CustomTextStyle.customOpenSans(
                            color: AppColors.blackColor,
                            fontSize: 20,
                          ),
                        ),
                        TextSpan(
                          text: 'Contact on - 9930024594',
                          style: CustomTextStyle.customOpenSans(
                            color: AppColors.blackColor,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                setHeight(height: 150),
              ],
            ),
          ),
      onInitialized: (controller) {
        AppLogger.info("Printer Controller Initialized!");
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
                  data: user.data?.name ?? '',
                  height: 90,
                  width: 175,
                ),
                const SizedBox(height: 2),
                // Text(
                //   user.name ?? 'Hisab Box',
                //   style: CustomTextStyle.customMontserrat(
                //     fontSize: 20, // Even larger for maximum visibility
                //     fontWeight: FontWeight.w800, // Extra bold
                //   ),
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                //   textAlign: TextAlign.center,
                // ),
                const SizedBox(height: 1),
                Text(
                  data['productData']['product'].name ?? '',
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
                  '${data['productData']['product'].flavor} | ${data['productData']['product'].weight} | ₹${data['productData']['product'].sellingPrice}',
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
