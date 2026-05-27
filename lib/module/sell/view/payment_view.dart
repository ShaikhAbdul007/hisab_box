import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/module/sell/controller/sell_list_after_scan_controller.dart';
import 'package:inventory/module/sell/widget/partialpayment_widget.dart';

/// Full-page payment screen — replaces the bottom sheet to avoid
/// scroll/keyboard/height constraint issues.
class PaymentView extends GetView<SellListAfterScanController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Payment',
      body: PartailPaymentWidget(controller: controller),
    );
  }
}
