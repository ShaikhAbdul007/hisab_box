import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/credits_amount/model/credit_model.dart';
import 'package:inventory/module/sell/controller/sell_list_after_scan_controller.dart';
import 'package:inventory/module/sell/widget/partialpayment_widget.dart';

class CreditPaymentConfirmView extends GetView<SellListAfterScanController> {
  const CreditPaymentConfirmView({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as CreditDataItem;
    final remainingAmount =
        double.tryParse(arguments.remainingAmount?.toString() ?? '') ?? 0.0;
    final customerName = arguments.nameOfCustomer ?? '';
    final customerMobile = arguments.mobileNo?.toString() ?? '';
    final customerAddress = arguments.customer?.address?.toString() ?? '';
    final billNo = arguments.billNo?.toString() ?? '';
    final dateOfCredit = arguments.dateOfCredit?.toString() ?? '';

    return CommonAppbar(
      appBarLabel: 'Credit Payment',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          //   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(16.r),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withValues(alpha: 0.05),
          //         blurRadius: 10,
          //         offset: const Offset(0, 3),
          //       ),
          //     ],
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         'Customer & Credit Details',
          //         style: CustomTextStyle.customOpenSans(
          //           fontSize: 12,
          //           color: Colors.grey.shade600,
          //         ),
          //       ),
          //       setHeight(height: 8),
          //       Text(
          //         customerName.isNotEmpty ? customerName : 'Unknown customer',
          //         style: CustomTextStyle.customPoppin(
          //           fontSize: 16,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //       if (customerMobile.isNotEmpty) ...[
          //         setHeight(height: 4),
          //         Text(
          //           customerMobile,
          //           style: CustomTextStyle.customOpenSans(
          //             fontSize: 12,
          //             color: Colors.grey.shade700,
          //           ),
          //         ),
          //       ],
          //       if (customerAddress.isNotEmpty) ...[
          //         setHeight(height: 4),
          //         Text(
          //           customerAddress,
          //           style: CustomTextStyle.customOpenSans(
          //             fontSize: 12,
          //             color: Colors.grey.shade700,
          //           ),
          //         ),
          //       ],
          //       if (billNo.isNotEmpty || dateOfCredit.isNotEmpty) ...[
          //         setHeight(height: 8),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             if (billNo.isNotEmpty)
          //               Text(
          //                 'Bill: $billNo',
          //                 style: CustomTextStyle.customOpenSans(
          //                   fontSize: 12,
          //                   color: Colors.grey.shade600,
          //                   fontWeight: FontWeight.bold,
          //                 ),
          //               ),
          //             if (dateOfCredit.isNotEmpty)
          //               Row(
          //                 children: [
          //                   Icon(
          //                     Icons.access_time,
          //                     size: 14.sp,
          //                     color: Colors.grey.shade600,
          //                   ),
          //                   setWidth(width: 2),
          //                   Text(
          //                     formatDateTime(dateOfCredit),
          //                     style: CustomTextStyle.customOpenSans(
          //                       fontSize: 12,
          //                       color: Colors.grey.shade600,
          //                     ),
          //                   ),
          //                   setWidth(width: 4),
          //                   Text(
          //                     formatDateTime(
          //                       showTime: true,
          //                       showDate: false,
          //                       dateOfCredit,
          //                     ),
          //                     style: CustomTextStyle.customOpenSans(
          //                       fontSize: 12,
          //                       color: Colors.grey.shade600,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //           ],
          //         ),
          //       ],
          //     ],
          //   ),
          // ),
          Expanded(
            child: PartailPaymentWidget(
              controller: controller,
              initialAmount: remainingAmount,
              confirmLabel: 'Confirm Payment',
              onConfirm: () {
                final cashAmount =
                    double.tryParse(controller.cashPaidController.text) ?? 0.0;
                final upiAmount =
                    double.tryParse(controller.upiPaidController.text) ?? 0.0;
                final cardAmount =
                    double.tryParse(controller.cardPaidController.text) ?? 0.0;
                final totalAmount = cashAmount + upiAmount + cardAmount;

                if (totalAmount == 0.0) {
                  showMessage(
                    message: 'Please enter at least one payment amount.',
                  );
                  return;
                }

                final selectedModes = <String>[];
                if (cashAmount > 0) selectedModes.add('cash');
                if (upiAmount > 0) selectedModes.add('upi');
                if (cardAmount > 0) selectedModes.add('card');
                final paymentMode =
                    selectedModes.length == 1 ? selectedModes.first : 'split';

                controller.creditAmountSelletment(
                  creditId: arguments.id.toString(),
                  body: {
                    'amount': totalAmount,
                    'payment_mode': paymentMode,
                    'cash_amount': cashAmount,
                    'upi_amount': upiAmount,
                    'card_amount': cardAmount,
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
