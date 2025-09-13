import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:intl/intl.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';

import '../../inventory/model/product_model.dart';

class InvoicePrinterView extends StatelessWidget {
  final List<ProductModel> scannedProductDetails;
  final String paymentMethod;
  final void Function(ReceiptController) onInitialized;
  final double totalAmount;
  final int discountPercentage;
  final int billNo;
  const InvoicePrinterView({
    super.key,
    required this.scannedProductDetails,
    required this.onInitialized,
    required this.paymentMethod,
    required this.totalAmount,
    required this.discountPercentage,
    required this.billNo,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);
    final formattedTime = DateFormat('HH:mm:ss').format(now);
    double total = totalAmount;
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
                        "Golden Pets",
                        style: CustomTextStyle.customMontserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      setHeight(height: 2),
                      Text(
                        '9768858160/8898359294',
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
                  "Shop No :06, Plotno: 61/62, Sector 19,Taj Avenue, Ulwe, Navi Mumbai",
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
                final itemTotal =
                    (item.sellingPrice ?? 0) * (item.quantity ?? 0);
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
                            setHeight(height: 10),
                            Text(
                              "${item.quantity} x ${item.sellingPrice}",
                              style: CustomTextStyle.customMontserrat(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "₹ $itemTotal",
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
                  // Center(
                  //   child: Text(
                  //     "Thank you for shopping!",
                  //     style: CustomTextStyle.customNato(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  // setHeight(height: 10),
                  // Center(
                  //   child: Text(
                  //     "Visit again!",
                  //     style: CustomTextStyle.customNato(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  // setHeight(height: 20),
                  // Divider(thickness: 1),
                  setHeight(height: 20),
                  Center(
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
                            text: "₹ $discountPercentage",
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
                ],
              ),

              setHeight(height: 150),
            ],
          ),
      onInitialized: onInitialized,
    );
  }
}
