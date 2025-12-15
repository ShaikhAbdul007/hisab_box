import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_padding.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/helper.dart';
import '../../../helper/textstyle.dart';
import '../controller/sell_list_after_scan_controller.dart';

class PartailPaymentWidget extends StatelessWidget {
  final SellListAfterScanController controller;
  const PartailPaymentWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    controller.openPaymentDialog(controller.finalTotal.value);
    return CustomPadding(
      paddingOption: SymmetricPadding(horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Row(
              children: [
                Text(
                  'Total Amount: ',
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 15,
                    color: AppColors.greyColor,
                  ),
                ),
                Text(
                  '${controller.paymentMethodTotalAmount.value}',
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 18,
                    color: AppColors.blackColor,
                  ),
                ),
                Spacer(),
                Obx(
                  () => Text(
                    'Remaining: ₹${controller.remainingAmount.value.toStringAsFixed(2)}',
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 16,
                      color:
                          controller.remainingAmount.value > 0
                              ? AppColors.redColor
                              : AppColors.greenColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          setHeight(height: 20),
          Obx(
            () => PartialpaymentWidget(
              imageString: 'assets/cash.png',
              readOnly: controller.allEditable.value,
              inValid: controller.isAmountValidCheck.value,
              payOnTap: () {
                var amount = double.parse(controller.cashPaidController.text);
                validationOnRemainingAmount(amount);
              },
              onChangeds: (val) {
                if (!controller.isAmountValid(val)) {
                  showSnackBar(
                    error:
                        "Amount can't be greater than total or remaining amount!",
                  );
                }
              },
              label: 'Cash',
              textEditingController: controller.cashPaidController,
            ),
          ),
          setHeight(height: 10),
          Obx(
            () => PartialpaymentWidget(
              imageString: 'assets/upiPayment.png',
              readOnly: controller.allEditable.value,
              inValid: controller.isAmountValidCheck.value,
              payOnTap: () {
                var amount = double.parse(controller.upiPaidController.text);
                validationOnRemainingAmount(amount);
              },
              onChangeds: (val) {
                if (!controller.isAmountValid(val)) {
                  showSnackBar(
                    error:
                        "Amount can't be greater than total or remaining amount!",
                  );
                }
              },
              label: 'UPI',
              textEditingController: controller.upiPaidController,
            ),
          ),
          setHeight(height: 10),
          Obx(
            () => PartialpaymentWidget(
              imageString: 'assets/card.png',
              readOnly: controller.allEditable.value,
              inValid: controller.isAmountValidCheck.value,
              payOnTap: () {
                var amount = double.parse(controller.cardPaidController.text);
                validationOnRemainingAmount(amount);
              },
              onChangeds: (val) {
                if (!controller.isAmountValid(val)) {
                  showSnackBar(
                    error:
                        "Amount can't be greater than total or remaining amount!",
                  );
                }
              },
              label: 'Card',
              textEditingController: controller.cardPaidController,
            ),
          ),
          setHeight(height: 10),
          Obx(
            () => PartialpaymentWidget(
              imageString: 'assets/creditamount.png',
              readOnly: controller.allEditable.value,
              inValid: controller.isAmountValidCheck.value,
              payOnTap: () {
                var amount = double.parse(controller.creditPaidController.text);
                validationOnRemainingAmount(amount);
              },
              onChangeds: (val) {
                if (!controller.isAmountValid(val)) {
                  showSnackBar(
                    error:
                        "Amount can't be greater than total or remaining amount!",
                  );
                }
              },
              label: 'Credit',
              textEditingController: controller.creditPaidController,
            ),
          ),
          setHeight(height: 10),
          Obx(
            () => PartialpaymentWidget(
              imageString: 'assets/roundoff.png',
              readOnly: controller.allEditable.value,
              inValid: controller.isAmountValidCheck.value,
              payOnTap: () {
                var amount = double.parse(
                  controller.roundOffPaidController.text,
                );
                validationOnRemainingAmount(amount);
              },
              onChangeds: (val) {
                if (!controller.isAmountValid(val)) {
                  showSnackBar(error: "Amount can't be greater than total!");
                }
              },
              label: 'Round Off',
              textEditingController: controller.roundOffPaidController,
            ),
          ),
          setHeight(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CommonButton(
                width: 150,
                label: 'Reset',
                onTap: () async {
                  controller.allEditable.value = !controller.allEditable.value;
                  controller.openPaymentDialog(controller.finalTotal.value);
                  controller.clear();
                },
              ),
              Obx(
                () => CommonButton(
                  isLoading: controller.isPartailLoading.value,
                  width: 150,
                  label: 'Sell',
                  onTap: () async {
                    if (controller.remainingAmount.value > 0) {
                      Get.back();
                      showMessage(
                        message: 'Please pay full amount before continuing!',
                      );
                    } else {
                      controller.getPrintReadyList();
                      await controller.saleConfirmed(
                        isLoading: controller.isPartailLoading,
                      );
                      controller.clear();
                      Get.back();
                    }
                  },
                ),
              ),
            ],
          ),
          setHeight(height: 50),
        ],
      ),
    );
  }

  void validationOnRemainingAmount(double amount) {
    if (amount > controller.remainingAmount.value) {
      showSnackBar(error: "Amount can't be greater than total!");
    } else {
      controller.updateRemainingAmount();
    }
  }
}

class PartialpaymentWidget extends StatelessWidget {
  final String label;
  final TextEditingController textEditingController;
  final Function(String)? onChangeds;
  final void Function() payOnTap;
  final String? Function(String?)? validator;
  final bool inValid;
  final bool readOnly;
  final String imageString;
  const PartialpaymentWidget({
    super.key,
    required this.label,
    required this.textEditingController,
    required this.payOnTap,
    this.onChangeds,
    this.validator,
    required this.inValid,
    required this.readOnly,
    required this.imageString,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomPadding(
          paddingOption: OnlyPadding(top: 28.0),
          child: Image.asset(imageString, width: 30, height: 40),
        ),
        Flexible(
          child: CommonTextField(
            astraIsRequred: false,
            readOnly: readOnly,
            validator: validator,
            onChanged: onChangeds,
            hintText: 'Enter amount',
            label: label,
            keyboardType: TextInputType.number,
            controller: textEditingController,
          ),
        ),
        CustomPadding(
          paddingOption: OnlyPadding(top: 28.0),
          child: CommonButton(
            width: 70,
            label: 'Pay',
            onTap: inValid ? payOnTap : () {},
          ),
        ),
        setWidth(width: 10),
      ],
    );
  }
}
