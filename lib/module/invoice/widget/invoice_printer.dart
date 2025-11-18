import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:intl/intl.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/sell/model/print_model.dart';

class InvoicePrinterView extends StatelessWidget with CacheManager {
  final List<PrintModel> scannedProductDetails;
  final String paymentMethod;
  final void Function(ReceiptController) onInitialized;
  InvoicePrinterView({
    super.key,
    required this.scannedProductDetails,
    required this.onInitialized,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    var user = retrieveUserDetail();
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);
    final formattedTime = DateFormat('HH:mm:ss').format(now);
    int billNo = retrieveBillNo();
    double total = 0;
    double savedAmount = 0;
    int discountPercentage = 0;
    return Receipt(
      backgroundColor: AppColors.whiteColor,
      builder:
          (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.blackColor,
                    child: Image.asset(
                      'assets/goldenpets logo.png',
                      height: 80,
                    ),
                  ),
                  setWidth(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.name}',
                        style: CustomTextStyle.customMontserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      setHeight(height: 2),
                      Text(
                        '${user.mobileNo}/${user.alternateMobileNo}',
                        style: CustomTextStyle.customMontserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              setHeight(height: 5),
              const Divider(color: AppColors.blackColor), setHeight(height: 10),
              Flexible(
                child: Text(
                  "${user.address},${user.city},${user.pincode}",
                  style: CustomTextStyle.customMontserrat(
                    fontSize: 18,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              setHeight(height: 10),
              const Divider(color: AppColors.blackColor),

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
                      '$billNo',
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
                      formattedDate,
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
                      formattedTime,
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
              const Divider(color: AppColors.blackColor),
              ...scannedProductDetails.map((item) {
                discountPercentage = item.discount ?? 0;
                total += (item.finalPrice ?? 0);
                savedAmount =
                    (item.originalPrice ?? 0) - (item.finalPrice ?? 0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
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
              const Divider(color: AppColors.blackColor),
              if (discountPercentage != 0.0) ...{
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        "Discount",
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
                        '₹ $discountPercentage',
                        textAlign: TextAlign.right,
                        style: CustomTextStyle.customMontserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                setHeight(height: 10),
              },
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

              // setHeight(height: 20),
              // BarcodeWidget(
              //   barcode: Barcode.qrCode(),
              //   data: '',
              //   height: 200,
              //   width: 500,
              //   drawText: false,
              // ),
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
                                text: "₹ ${savedAmount.floor()}",
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
              setHeight(height: 150),
            ],
          ),
      onInitialized: onInitialized,
    );
  }
}
