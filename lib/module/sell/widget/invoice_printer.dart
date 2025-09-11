import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:intl/intl.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';

import '../../inventory/model/product_model.dart';

class InvoicePrinterView extends StatelessWidget {
  final List<ProductModel> scannedProductDetails;
  final void Function(ReceiptController) onInitialized;
  const InvoicePrinterView({
    super.key,
    required this.scannedProductDetails,
    required this.onInitialized,
  });

  @override
  Widget build(BuildContext context) {
    // 🕒 Current date-time
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);
    final formattedTime = DateFormat('HH:mm:ss').format(now);

    // 🧮 Total Calculation
    double total = scannedProductDetails.fold(
      0,
      (sum, item) => sum + (item.sellingPrice ?? 0) * (item.quantity ?? 0),
    );

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
                    radius: 40,
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
              const Divider(color: AppColors.blackColor),
              Text(
                "Shop No :06, Plotno: 61/62, Sector 19,\nTaj Avenue, Ulwe,Navi Mumbai",
                style: CustomTextStyle.customMontserrat(fontSize: 18),
              ),
              const Divider(color: AppColors.blackColor),
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
                      'Cash',
                      style: CustomTextStyle.customMontserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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
                                fontSize: 20,
                              ),
                            ),
                            setHeight(height: 5),
                            Text(
                              "${item.quantity} x ${item.sellingPrice}",
                              style: CustomTextStyle.customMontserrat(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "$itemTotal",
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
                      "$total",
                      textAlign: TextAlign.right,
                      style: CustomTextStyle.customMontserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.blackColor),
              setHeight(height: 20),
              Center(
                child: Text(
                  "Scan barcode to give review !",
                  style: CustomTextStyle.customNato(fontSize: 26),
                ),
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
              Center(
                child: Text(
                  "Thank you for shopping !",
                  style: CustomTextStyle.customNato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              setHeight(height: 10),
              Center(
                child: Text(
                  "Visit again !",
                  style: CustomTextStyle.customNato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              setHeight(height: 150),
            ],
          ),
      onInitialized: onInitialized,
    );
  }
}
