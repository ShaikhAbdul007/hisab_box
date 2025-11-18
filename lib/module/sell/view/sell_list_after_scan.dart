import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_radio_button.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/module/sell/model/print_model.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_bottom_sheet.dart';
import '../../../helper/app_message.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/routes.dart';
import '../../loose_sell/widget/loose_sell_bottomsheet_component.dart';
import '../controller/sell_list_after_scan_controller.dart';
import '../widget/payment_method_widget.dart';
import '../widget/selling_confirmatio_list_text.dart';

class SellListAfterScan extends GetView<SellListAfterScanController> {
  const SellListAfterScan({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CommonAppbar(
        appBarLabel: sellingProduct,
        firstActionChild: InkWell(
          onTap: () async {
            Get.offNamed(
              AppRouteName.inventoryView,
              arguments: {'flag': false},
            );
          },
          child: CommonContainer(
            height: 40,
            width: 40,
            radius: 10,
            color: AppColors.whiteColor,
            child: Icon(
              CupertinoIcons.barcode_viewfinder,
              color: AppColors.blackColor,
            ),
          ),
        ),
        persistentFooterButtons: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                controller.discountPerProduct.value
                    ? Row(
                      children: [
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width / 1.5,
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
                                    groupValue: controller.discountValue.value,
                                    onChanged: (val) {
                                      controller.discountValue.value = val ?? 0;
                                      controller.isDiscountGiven.value = true;
                                      controller.calculateDiscount();
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        setWidth(width: 20),
                        Obx(
                          () =>
                              controller.isDiscountGiven.value
                                  ? InkWell(
                                    onTap: () {
                                      controller.isDiscountGiven.value = false;
                                      controller.discountValue.value = 0;
                                      controller.discountDifferenceAmount = 0.0;
                                      controller.amount.text =
                                          controller.totalAmount.value
                                              .toString();
                                    },
                                    child: Icon(
                                      CupertinoIcons.clear_fill,
                                      color: AppColors.blackColor,
                                      //size: 20,
                                    ),
                                  )
                                  : Container(),
                        ),
                      ],
                    )
                    : Container(),
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Actuall Price',
                            style: CustomTextStyle.customUbuntu(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: " : ",
                                style: CustomTextStyle.customMontserrat(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text:
                                    controller
                                        .getTotalAmount()
                                        .toDouble()
                                        .toString(),
                                style: CustomTextStyle.customMontserrat(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(
                          () => RichText(
                            text: TextSpan(
                              text: 'Total',
                              style: CustomTextStyle.customUbuntu(
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: " : ",
                                  style: CustomTextStyle.customMontserrat(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: controller.finalTotal.value
                                      .toStringAsFixed(2),
                                  style: CustomTextStyle.customMontserrat(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Obx(
                        //   () => Text(
                        //     controller.discountPerProduct.value
                        //         ? controller.finalTotal.value.toString()
                        //         : controller.isDiscountGiven.value
                        //         ? controller.discountPrice.value.toString()
                        //         : controller.getTotalAmount().toString(),
                        //     style: CustomTextStyle.customUbuntu(fontSize: 20),
                        //   ),
                        // ),
                        setHeight(height: 10),
                      ],
                    ),
                    Spacer(),
                    CommonButton(
                      height: 40,
                      width: 150,
                      //  isLoading: controller.isSaleLoading.value,
                      label: 'Sell',
                      onTap: () async {
                        showPaymentMethod(
                          context,
                          controller.finalTotal.value,
                          controller,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        body: Obx(
          () =>
              controller.productList.isNotEmpty
                  ? Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: controller.productList.length,
                          itemBuilder: (context, index) {
                            return SellingConfirmationListText(
                              onDiscountChanged: (value) {
                                controller.discountCalculateAsPerProduct(index);
                                controller.calculateTotalWithDiscount();
                              },
                              dicountController:
                                  controller.perProductDiscount[index],
                              sellingPrices: Obx(
                                () => Text(
                                  controller.sellingPriceList[index].toString(),
                                  style: CustomTextStyle.customPoppin(
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                              removeOnTap: () {
                                controller.productList.remove(
                                  controller.productList[index],
                                );
                                controller.saveProductList(
                                  controller.productList,
                                );
                              },
                              minusOnTap: () {
                                controller.updateQuantity(false, index);
                              },

                              plusOnTap: () {
                                controller.updateQuantity(true, index);
                              },

                              inventoryModel: controller.productList[index],
                            );
                          },
                        ),
                      ),
                    ],
                  )
                  : CommonNodatafound(message: 'No product found for sell'),
        ),
      ),
    );
  }

  void openManuallySaleBottomSheet({required GlobalKey<FormState> formkeys}) {
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

  void showPaymentMethod(
    BuildContext context,
    double amount,
    SellListAfterScanController controller,
  ) {
    commonBottomSheet(
      label: 'Payment Method',
      onPressed: () {
        Get.back();
      },
      child: PaymentMethodWidget(amount: amount, controller: controller),
    );
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