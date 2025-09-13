import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_radio_button.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/sell/widget/invoice_printer.dart';
import 'package:inventory/routes/routes.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_bottom_sheet.dart';
import '../../../common_widget/common_dialogue.dart';
import '../../../common_widget/common_popup_appbar.dart';
import '../../../helper/textstyle.dart';
import '../../loose_sell/widget/loose_sell_bottomsheet_component.dart';
import '../controller/sell_list_after_scan_controller.dart';
import '../widget/selling_confirmatio_list_text.dart';

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
                            return Obx(
                              () => SellingConfirmationListText(
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
                                plusOnTap:
                                    controller.isStockOver.value
                                        ? () {
                                          print('isstockover');
                                        }
                                        : () {
                                          controller.updateQuantity(
                                            controller.productList[index],
                                            true,
                                            index,
                                            controller
                                                    .productList[index]
                                                    .barcode ??
                                                '',
                                          );
                                        },
                                inventoryModel: controller.productList[index],
                              ),
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
                                                controller
                                                        .discountDifferenceAmount =
                                                    0.0;
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
                            showPaymentMethod(context);
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

  showPaymentMethod(BuildContext context) {
    commonDialogBox(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonPopupAppbar(
            label: 'Payment Method',
            onPressed: () {
              Get.back();
            },
          ),
          Divider(),
          Text(
            'Choose a payment method',
            style: CustomTextStyle.customUbuntu(
              fontSize: 15,
              color: AppColors.greyColor,
            ),
          ),
          setHeight(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CommonButton(
                width: 120,
                label: cashLabel,
                onTap: () {
                  Get.back();
                  controller.billNo.value++;
                  givePrint(
                    billNo: controller.billNo.value,
                    discountPercentage:
                        controller.discountDifferenceAmount.toInt(),
                    context: context,
                    paymentMethod: cashLabel,
                    totalAmount:
                        controller.isDiscountGiven.value
                            ? controller.discountPrice.value
                            : controller.getTotalAmount().toDouble(),
                  );
                },
              ),
              CommonButton(
                isbgReq: true,
                bgColor: AppColors.greenColor,
                width: 120,
                label: onlineLabel,
                onTap: () {
                  Get.back();
                  controller.billNo.value++;
                  givePrint(
                    billNo: controller.billNo.value,
                    discountPercentage:
                        controller.discountDifferenceAmount.toInt(),
                    totalAmount:
                        controller.isDiscountGiven.value
                            ? controller.discountPrice.value
                            : controller.getTotalAmount().toDouble(),
                    context: context,
                    paymentMethod: onlineLabel,
                  );
                },
              ),
            ],
          ),
          setHeight(height: 20),
          CommonButton(
            isbgReq: true,
            bgColor: AppColors.redColor,
            width: 250,
            label: creditLabel,
            onTap: () {
              Get.back();
              controller.billNo.value++;
              givePrint(
                billNo: controller.billNo.value,
                discountPercentage: controller.discountDifferenceAmount.toInt(),
                context: context,
                paymentMethod: creditLabel,
                totalAmount:
                    controller.isDiscountGiven.value
                        ? controller.discountPrice.value
                        : controller.getTotalAmount().toDouble(),
              );
            },
          ),
          setHeight(height: 20),
        ],
      ),
    );
  }

  givePrint({
    required BuildContext context,
    required String paymentMethod,
    required double totalAmount,
    required int discountPercentage,
    required int billNo,
  }) {
    commonDialogBox(
      context: context,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonPopupAppbar(
              label: 'Invoice Preview',
              onPressed: () {
                Get.back();
                controller.billNo.value--;
              },
            ),
            InvoicePrinterView(
              billNo: billNo,
              totalAmount: totalAmount,
              paymentMethod: paymentMethod,
              onInitialized: (p0) => controller.setReceiptController(p0),
              scannedProductDetails: controller.scannedProductDetails,
              discountPercentage: discountPercentage,
            ),
            Obx(
              () => CommonButton(
                isLoading: controller.isPrintingLoading.value,
                label: "Print Invoice",
                onTap: () async {
                  bool checkBluetooth =
                      await controller.checkBluetoothConnectivity();
                  if (checkBluetooth == true) {
                    if (controller.receiptController.value != null) {
                      await printReceipt(
                        rController: controller.receiptController.value!,
                        context: context,
                        paymentMethod: paymentMethod,
                      );
                    }
                  } else {
                    showMessage(message: 'Bluetooth is off, please on it.');
                  }
                },
              ),
            ),
            setHeight(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> printReceipt({
    required ReceiptController rController,
    required BuildContext context,
    required String paymentMethod,
  }) async {
    controller.isPrintingLoading.value = true;
    String? device = controller.retrievePrinterAddress();

    if (device != null) {
      if (paymentMethod == 'Credit') {
        var res = await rController.print(address: device, delayTime: 0);
        if (res == true) {
          controller.isPrintingLoading.value = false;
          Get.back();
        }
      } else {
        bool saleConfirm = await controller.confirmSale(
          paymentMethod: paymentMethod,
        );
        if (saleConfirm == true) {
          var res = await rController.print(address: device, delayTime: 0);
          if (res == true) {
            controller.isPrintingLoading.value = false;
            AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
          }
        } else {
          controller.isPrintingLoading.value = false;
          Get.back();
        }
      }
    } else {
      controller.isPrintingLoading.value = false;
      commonDialogBox(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonPopupAppbar(
              label: 'Bluetooth Info',
              onPressed: () {
                Get.back();
              },
            ),
            const Divider(),
            RichText(
              text: TextSpan(
                style: CustomTextStyle.customMontserrat(),
                children: [
                  TextSpan(
                    text:
                        'Please connect your printer before printing the invoice.\nSteps to set up the printer:\n',
                  ),
                  TextSpan(
                    text: '1. ',
                    style: CustomTextStyle.customUbuntu(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: 'Go to Settings\n'),
                  TextSpan(
                    text: '2. ',
                    style: CustomTextStyle.customUbuntu(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: 'Click on App Settings\n'),
                  TextSpan(
                    text: '3. ',
                    style: CustomTextStyle.customUbuntu(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: 'Select Printer Option\n'),
                  TextSpan(
                    text: '4. ',
                    style: CustomTextStyle.customUbuntu(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: 'Save your preferred printer'),
                ],
              ),
            ),

            setHeight(height: 8),
            CommonButton(
              label: 'ok',
              onTap: () {
                Get.back();
                AppRoutes.navigateRoutes(routeName: AppRouteName.appsetting);
              },
            ),
            setHeight(height: 15),
          ],
        ),
      );
    }
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
    return CommonRadioButton(
      label: label,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
 // final upiDetails = UPIDetails(
                  //   upiID: "8892359294@ybl",
                  //   payeeName: "GoldenPets",
                  //   amount: 100,
                  // );
                  // commonBottomSheet(
                  //   label: 'Scan Qr Code',
                  //   onPressed: () {
                  //     Get.back();
                  //   },
                  //   child: Column(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       UPIPaymentQRCode(
                  //         upiDetails: upiDetails,
                  //         size: 200,
                  //         eyeStyle: const QrEyeStyle(
                  //           eyeShape: QrEyeShape.square,
                  //           color: AppColors.greyColor,
                  //         ),
                  //       ),
                  //       setHeight(height: 50),
                  //       CommonButton(
                  //         label: 'Print',
                  //         onTap: () {
                           
                  //         },
                  //       ),
                  //       setHeight(height: 20),
                  //     ],
                  //   ),
                  // );