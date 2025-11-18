import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../module/sell/controller/sell_list_after_scan_controller.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_bottom_sheet.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/size.dart';
import '../../../helper/app_message.dart';
import '../../../helper/textstyle.dart';
import 'partialpayment_widget.dart';

class PaymentMethodWidget extends StatelessWidget {
  final SellListAfterScanController controller;
  final double amount;
  const PaymentMethodWidget({
    super.key,
    required this.controller,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Choose a payment method',
          style: CustomTextStyle.customUbuntu(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.greyColor,
          ),
        ),
        setHeight(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(
              () => CommonButton(
                isLoading: controller.isCashLoading.value,
                width: 150,
                label: cashLabel,
                onTap: () async {
                  controller.getPrintReadyList();
                  await controller.saleConfirmAndPrintInvoice(
                    paymentMethod: cashLabel,

                    isLoading: controller.isCashLoading,
                  );
                },
              ),
            ),
            Obx(
              () => CommonButton(
                isLoading: controller.isOnlineLoading.value,
                isbgReq: true,
                bgColor: AppColors.greenColor,
                width: 150,
                label: onlineLabel,
                onTap: () async {
                  controller.getPrintReadyList();
                  await controller.saleConfirmAndPrintInvoice(
                    isLoading: controller.isOnlineLoading,
                    paymentMethod: onlineLabel,
                  );
                },
              ),
            ),
          ],
        ),
        setHeight(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(
              () => CommonButton(
                isLoading: controller.isCardLoading.value,
                width: 150,
                label: cardLabel,
                bgColor: AppColors.deepPurple,
                onTap: () async {
                  controller.getPrintReadyList();
                  await controller.saleConfirmAndPrintInvoice(
                    paymentMethod: cardLabel,
                    isLoading: controller.isCardLoading,
                  );
                },
              ),
            ),
            CommonButton(
              isbgReq: true,
              bgColor: AppColors.greyColor,
              width: 150,
              label: partialLabel,
              onTap: () {
                Get.back();
                commonBottomSheet(
                  label: 'Choose Payment Method',
                  onPressed: () {
                    Get.back();
                    controller.clear();
                  },
                  child: PartailPaymentWidget(controller: controller),
                );
              },
            ),
          ],
        ),
        setHeight(height: 50),
      ],
    );
  }
}
