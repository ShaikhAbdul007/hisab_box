import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_padding.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/helper.dart';
import '../../../helper/textstyle.dart';
import '../controller/sell_list_after_scan_controller.dart';

// ── Main payment widget — StatefulWidget to avoid setState-during-build ────────
class PartailPaymentWidget extends StatefulWidget {
  final SellListAfterScanController controller;
  const PartailPaymentWidget({super.key, required this.controller});

  @override
  State<PartailPaymentWidget> createState() => _PartailPaymentWidgetState();
}

class _PartailPaymentWidgetState extends State<PartailPaymentWidget> {
  SellListAfterScanController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    // Defer state mutation until after the first frame — fixes
    // "setState() called during build" error from Obx
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.openPaymentDialog(c.finalTotal.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Fixed header ─────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
          child: Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.blackColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                      setHeight(height: 2),
                      Text(
                        '₹${c.paymentMethodTotalAmount.value.toStringAsFixed(2)}',
                        style: CustomTextStyle.customPoppin(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Remaining',
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                      setHeight(height: 2),
                      Text(
                        '₹${c.remainingAmount.value.toStringAsFixed(2)}',
                        style: CustomTextStyle.customPoppin(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color:
                              c.remainingAmount.value > 0
                                  ? Colors.red.shade300
                                  : Colors.green.shade300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        setHeight(height: 12),

        // ── Scrollable rows via CustomScrollView + SliverList ─────
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _PaymentRow(
                      mode: 'cash',
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      iconColor: const Color(0xFF2E7D32),
                      label: 'Cash',
                      controller: c,
                      textEditingController: c.cashPaidController,
                    ),
                    setHeight(height: 8),
                    _PaymentRow(
                      mode: 'upi',
                      icon: CupertinoIcons.qrcode,
                      iconColor: const Color(0xFF6A1B9A),
                      label: 'UPI',
                      controller: c,
                      textEditingController: c.upiPaidController,
                    ),
                    setHeight(height: 8),
                    _PaymentRow(
                      mode: 'card',
                      icon: CupertinoIcons.creditcard_fill,
                      iconColor: const Color(0xFF1565C0),
                      label: 'Card',
                      controller: c,
                      textEditingController: c.cardPaidController,
                    ),
                    setHeight(height: 8),
                    _PaymentRow(
                      mode: 'credit',
                      icon: CupertinoIcons.person_crop_circle_badge_minus,
                      iconColor: const Color(0xFFC62828),
                      label: 'Credit',
                      controller: c,
                      textEditingController: c.creditPaidController,
                    ),
                    setHeight(height: 8),
                    _PaymentRow(
                      mode: 'round_off',
                      icon: CupertinoIcons.arrow_2_circlepath,
                      iconColor: const Color(0xFF37474F),
                      label: 'Round Off',
                      controller: c,
                      textEditingController: c.roundOffPaidController,
                    ),
                    setHeight(height: 20),

                    // ── Confirm Sale ───────────────────────────────
                    Obx(() {
                      final enabled = c.isConfirmEnabled;
                      return Opacity(
                        opacity: enabled ? 1.0 : 0.4,
                        child: CommonButton(
                          isLoading: c.isPartailLoading.value,
                          label: 'Confirm Sale',
                          onTap:
                              enabled
                                  ? () async {
                                    await c.saleConfirmed(
                                      isLoading: c.isPartailLoading,
                                    );
                                    c.clearPaymentInputs();
                                    Get.back();
                                  }
                                  : () {
                                    showMessage(
                                      message:
                                          'Please pay full amount before continuing!',
                                    );
                                  },
                        ),
                      );
                    }),
                    setHeight(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Payment Row ───────────────────────────────────────────────────────────────
class _PaymentRow extends StatelessWidget {
  final String mode;
  final IconData icon;
  final Color iconColor;
  final String label;
  final SellListAfterScanController controller;
  final TextEditingController textEditingController;

  const _PaymentRow({
    required this.mode,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.controller,
    required this.textEditingController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isPaid = controller.paidModes.contains(mode);
      return Opacity(
        opacity: isPaid ? 0.55 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isPaid ? iconColor.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color:
                  isPaid
                      ? iconColor.withValues(alpha: 0.3)
                      : Colors.grey.shade100,
            ),
            boxShadow:
                isPaid
                    ? []
                    : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.h,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: 18.sp),
              ),
              setWidth(width: 10),
              Expanded(
                child: CommonTextField(
                  astraIsRequred: false,
                  readOnly: isPaid,
                  onChanged: (val) {
                    final double entered = double.tryParse(val) ?? 0;
                    if (entered > controller.remainingAmount.value) {
                      showSnackBar(
                        error:
                            "Amount can't exceed remaining ₹${controller.remainingAmount.value.toStringAsFixed(2)}",
                      );
                      textEditingController.text = controller.remainingAmount.value.toStringAsFixed(2);
                      textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));
                    }
                  },
                  hintText: '0.00',
                  label: label,
                  keyboardType: TextInputType.number,
                  controller: textEditingController,
                ),
              ),
              setWidth(width: 8),
              InkWell(
                onTap: () {
                  if (isPaid) {
                    controller.clearModePayment(mode, textEditingController);
                  } else {
                    controller.validateAndPay(mode, textEditingController);
                  }
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color:
                        isPaid
                            ? Colors.red.withValues(alpha: 0.1)
                            : iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          isPaid
                              ? Colors.red.withValues(alpha: 0.4)
                              : iconColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    isPaid
                        ? CupertinoIcons.xmark_circle_fill
                        : CupertinoIcons.checkmark_alt,
                    size: 18.sp,
                    color: isPaid ? AppColors.redColor : iconColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── PartialpaymentWidget kept for backward compat ─────────────────────────────
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
