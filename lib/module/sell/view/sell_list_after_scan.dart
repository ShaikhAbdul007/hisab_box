import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/module/inventory/model/product_model.dart';
import 'package:printing/printing.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_bottom_sheet.dart';
import '../../../helper/textstyle.dart';
import '../../loose_sell/widget/loose_sell_bottomsheet_component.dart';
import '../controller/sell_list_after_scan_controller.dart';
import '../widget/selling_confirmatio_list_text.dart';
import 'package:pdf/widgets.dart' as pw;

class SellListAfterScan extends GetView<SellListAfterScanController> {
  const SellListAfterScan({super.key});

  @override
  Widget build(BuildContext context) {
    final form = GlobalKey<FormState>();
    return CommonAppbar(
      appBarLabel: 'Selling Product',
      // firstActionChild: AddExpensesButton(
      //   onTap: () {
      //     openManuallySaleBottomSheet(formkeys: form);
      //   },
      // ),
      body: Obx(
        () =>
            controller.productList.isNotEmpty
                ? SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(style: BorderStyle.solid),
                        ),
                        height: 550,
                        child: ListView.builder(
                          itemCount: controller.productList.length,
                          itemBuilder: (context, index) {
                            return SellingConfirmationListText(
                              sellingPrices: Obx(
                                () => Text(
                                  controller
                                      .getSellingPriceAsPerQuantity(
                                        controller.productList[index],
                                        index,
                                      )
                                      .toString(),
                                  style: CustomTextStyle.customPoppin(
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                              removeOnTap: () {
                                controller.productList.remove(
                                  controller.productList[index],
                                );
                              },
                              minusOnTap: () {
                                controller.updateQuantity(
                                  controller.productList[index],
                                  false,
                                  index,
                                  controller.productList[index].barcode ?? '',
                                );
                              },
                              plusOnTap: () {
                                controller.updateQuantity(
                                  controller.productList[index],
                                  true,
                                  index,
                                  controller.productList[index].barcode ?? '',
                                );
                              },
                              inventoryModel: controller.productList[index],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 50,
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: controller.discountList.length,
                                    itemBuilder: (context, index) {
                                      var list = controller.discountList[index];
                                      return SizedBox(
                                        width: 80,
                                        child: Obx(
                                          () => DiscountRadioButton(
                                            label: list.label.toString(),
                                            groupValue:
                                                controller.discountValue.value,
                                            onChanged: (val) {
                                              controller.discountValue.value =
                                                  val ?? 0;
                                              controller.isDiscountGiven.value =
                                                  true;
                                              controller.calculateDiscount();
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Obx(
                                  () =>
                                      controller.isDiscountGiven.value
                                          ? CommonContainer(
                                            color: AppColors.blackColor,
                                            height: 30,
                                            width: 40,
                                            radius: 5,
                                            child: IconButton(
                                              icon: Icon(
                                                CupertinoIcons.clear,
                                                color: AppColors.whiteColor,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                controller
                                                    .isDiscountGiven
                                                    .value = false;
                                                controller.discountValue.value =
                                                    0;
                                                controller.amount.text =
                                                    controller.totalAmount.value
                                                        .toString();
                                              },
                                            ),
                                          )
                                          : Container(),
                                ),
                              ],
                            ),
                            setHeight(height: 10),
                            Row(
                              children: [
                                Text(
                                  'Selling Price : ',
                                  style: CustomTextStyle.customNato(
                                    fontSize: 15,
                                    color: AppColors.blackColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  controller.getTotalAmount().toString(),
                                  style: CustomTextStyle.customUbuntu(
                                    fontSize: 18,
                                    color: AppColors.redColor,
                                  ),
                                ),
                                setWidth(width: 100),
                                Container(
                                  height: 30,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(),
                                  ),
                                  child: Center(
                                    child: Obx(
                                      () => Text(
                                        controller.isDiscountGiven.value
                                            ? controller.discountPrice.value
                                                .toString()
                                            : controller
                                                .getTotalAmount()
                                                .toString(),
                                        style: CustomTextStyle.customUbuntu(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Divider(endIndent: 10, indent: 10),
                      Obx(
                        () => CommonButton(
                          isLoading: controller.isSaleLoading.value,
                          label: 'Sell',
                          onTap: () async {
                            print(
                              'controller.productList is quantity ${controller.productList[0].quantity}',
                            );
                            print(
                              'controller.productList is barcode ${controller.productList[0].barcode}',
                            );
                            print(
                              'controller.productList is sellingPrice ${controller.productList[0].sellingPrice}',
                            );
                            print(
                              'controller.productList is name ${controller.productList[0].name}',
                            );
                            // await controller.confirmSale();
                            printInvoice(controller.scannedProductDetails);
                          },
                        ),
                      ),
                    ],
                  ),
                )
                : CommonNodatafound(message: 'No product found for sell'),
      ),
    );
  }

  openManuallySaleBottomSheet({required GlobalKey<FormState> formkeys}) {
    commonBottomSheet(
      label: 'Add Manually',
      onPressed: () {
        Get.back();
      },
      child: LooseSellBottomsheetComponent(
        controller: controller,
        formkeys: formkeys,
      ),
    );
  }

  void printInvoice(List<ProductModel> scannedProductDetails) async {
    final pdf = pw.Document();

    // 🕒 Get current date and time
    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);

    // 🖼️ Load image from assets
    final Uint8List imageData = await rootBundle
        .load('assets/goldenpets logo.png')
        .then((value) => value.buffer.asUint8List());
    final logo = pw.MemoryImage(imageData);

    double total = scannedProductDetails.fold(
      0,
      (sum, item) => sum + (item.sellingPrice ?? 0) * item.quantity!,
    );

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 🖼️ Logo at the top
                pw.Center(child: pw.Image(logo, height: 80)),
                pw.SizedBox(height: 10),

                // 🕒 Date/time
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Date: $formattedDate',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.SizedBox(height: 20),

                // 🧾 Invoice title
                pw.Text(
                  "🧾 Invoice",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),

                // 📦 Product Table
                pw.TableHelper.fromTextArray(
                  headers: ['Item', 'Qty', 'Price', 'Total'],
                  data:
                      scannedProductDetails.map((p) {
                        return [
                          p.name,
                          p.quantity.toString(),
                          (p.sellingPrice! * p.quantity!).toStringAsFixed(2),
                          (p.sellingPrice! * p.quantity!).toStringAsFixed(2),
                        ];
                      }).toList(),
                  cellAlignment: pw.Alignment.centerLeft,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  border: pw.TableBorder.all(),
                ),
                pw.SizedBox(height: 20),

                // 💸 Total
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "Grand Total: ₹${total.toStringAsFixed(2)}",
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}

class DiscountRadioButton extends StatelessWidget {
  final String label;
  final int groupValue;
  final void Function(int?)? onChanged;
  const DiscountRadioButton({
    super.key,
    required this.label,
    required this.groupValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      activeColor: AppColors.blackColor,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: CustomTextStyle.customPoppin()),
      value: int.parse(label),
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
