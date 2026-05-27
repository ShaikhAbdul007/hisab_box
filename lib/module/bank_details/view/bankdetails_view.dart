import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/edit_mode_banner.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/keys/keys.dart';
import 'package:inventory/module/bank_details/controller/bankdetails_controller.dart';

class BankdetailsView extends GetView<BankDetailsController> {
  const BankdetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Bank Details',
      firstActionChild: Obx(
        () => InkWell(
          onTap: () => controller.readOnly.value = !controller.readOnly.value,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  controller.readOnly.value
                      ? Colors.grey.shade100
                      : AppColors.blackColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              controller.readOnly.value
                  ? CupertinoIcons.pencil
                  : CupertinoIcons.checkmark_alt,
              size: 20.sp,
              color:
                  controller.readOnly.value
                      ? AppColors.greyColor
                      : AppColors.blackColor,
            ),
          ),
        ),
      ),
      body: Obx(
        () =>
            controller.setBankDetailsUpi.value
                ? const CommonProgressBar(color: AppColors.blackColor)
                : Form(
                  key: formkeys,
                  child: ListView(
                    padding:
                        SymmetricPadding(
                          horizontal: 16,
                          vertical: 16,
                        ).getPadding(),
                    children: [
                      // ── Info banner ──────────────────────────────────────
                      EditModeBanner(
                        readOnly: controller.readOnly,
                        readOnlyMessage:
                            'Tap the edit icon (top right) to update your bank details.',
                        editingMessage:
                            'You are in edit mode. Make changes and tap Save.',
                      ),
                      setHeight(height: 20),

                      // ── Bank info card ───────────────────────────────────
                      _SectionCard(
                        icon: Icons.account_balance_rounded,
                        iconColor: const Color(0xFF1565C0),
                        title: 'Bank Information',
                        children: [
                          CommonTextField(
                            readOnly: controller.readOnly.value,
                            hintText: 'e.g. State Bank of India',
                            label: 'Bank Name',
                            controller: controller.bankNameController,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Bank name is required';
                              }
                              if (v.trim().length < 3) {
                                return 'Bank name must be at least 3 letters';
                              }
                              return null;
                            },
                          ),
                          setHeight(height: 8),
                          CommonTextField(
                            readOnly: controller.readOnly.value,
                            hintText: 'e.g. Rahul Sharma',
                            label: 'Account Holder Name',
                            controller: controller.accountHolderNameController,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Account holder name is required';
                              }
                              if (!RegExp(
                                r'^[a-zA-Z\s.]{3,}$',
                              ).hasMatch(v.trim())) {
                                return 'Enter a valid name (letters only)';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      setHeight(height: 16),

                      // ── UPI card ─────────────────────────────────────────
                      _SectionCard(
                        icon: CupertinoIcons.qrcode,
                        iconColor: const Color(0xFF6A1B9A),
                        title: 'UPI Details',
                        children: [
                          CommonTextField(
                            readOnly: controller.readOnly.value,
                            hintText: 'e.g. name@upi',
                            label: 'UPI ID',
                            controller: controller.upiIdController,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'UPI ID is required';
                              }
                              if (!controller.isValidUpi(v.trim())) {
                                return 'Enter a valid UPI ID (example: name@bank)';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      setHeight(height: 28),

                      // ── Save button ──────────────────────────────────────
                      Obx(
                        () =>
                            controller.readOnly.value
                                ? const SizedBox.shrink()
                                : CustomPadding(
                                  paddingOption: SymmetricPadding(
                                    horizontal: 20,
                                  ),
                                  child: CommonButton(
                                    isLoading: controller.bankDetailsUpi.value,
                                    label: 'Save Changes',
                                    onTap: () {
                                      if (formkeys.currentState!.validate()) {
                                        unfocus();
                                        controller.saveBankDetails();
                                      }
                                    },
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: iconColor, size: 18.sp),
              ),
              setWidth(width: 10),
              Text(
                title,
                style: CustomTextStyle.customPoppin(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          setHeight(height: 14),
          ...children,
        ],
      ),
    );
  }
}
