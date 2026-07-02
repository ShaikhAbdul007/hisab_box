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
import 'package:inventory/responsive_layout/dimension.dart';

class BankdetailsView extends GetView<BankDetailsController> {
  const BankdetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            'Bank Details',
            style: CustomTextStyle.customNato(fontSize: 16),
          ),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Get.back(),
          ),
          actions: [
            Obx(
              () => InkWell(
                onTap:
                    () =>
                        controller.readOnly.value = !controller.readOnly.value,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        controller.readOnly.value
                            ? Colors.grey.shade100
                            : AppColors.blackColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    controller.readOnly.value
                        ? CupertinoIcons.pencil
                        : CupertinoIcons.checkmark_alt,
                    size: 20,
                    color:
                        controller.readOnly.value
                            ? AppColors.greyColor
                            : AppColors.blackColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
          surfaceTintColor: AppColors.greyColorShade100,
          backgroundColor: AppColors.greyColorShade100,
        ),
        body: Obx(
          () =>
              controller.setBankDetailsUpi.value
                  ? const Center(
                    child: CommonProgressBar(color: AppColors.blackColor),
                  )
                  : Form(
                    key: formkeys,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column (flex 3): Bank Information
                          Expanded(
                            flex: 3,
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                EditModeBanner(
                                  readOnly: controller.readOnly,
                                  readOnlyMessage:
                                      'Tap the edit icon (top right) to update your bank details.',
                                  editingMessage:
                                      'You are in edit mode. Make changes and tap Save.',
                                ),
                                const SizedBox(height: 20),
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
                                    const SizedBox(height: 12),
                                    CommonTextField(
                                      readOnly: controller.readOnly.value,
                                      hintText: 'e.g. Rahul Sharma',
                                      label: 'Account Holder Name',
                                      controller:
                                          controller
                                              .accountHolderNameController,
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
                                const SizedBox(height: 24),
                                Obx(
                                  () =>
                                      controller.readOnly.value
                                          ? const SizedBox.shrink()
                                          : CommonButton(
                                            isLoading:
                                                controller.bankDetailsUpi.value,
                                            label: 'Save Changes',
                                            onTap: () {
                                              if (formkeys.currentState!
                                                  .validate()) {
                                                unfocus();
                                                controller.saveBankDetails();
                                              }
                                            },
                                          ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Right column (flex 2): UPI Details & Payment Mock Card
                          Expanded(
                            flex: 2,
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
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
                                const SizedBox(height: 24),
                                // Interactive Payment card display
                                _MockPaymentCard(
                                  bankName: controller.bankNameController.text,
                                  holderName:
                                      controller
                                          .accountHolderNameController
                                          .text,
                                  upiId: controller.upiIdController.text,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        ),
      );
    }

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
    final bool desktop = isDesktop(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(desktop ? 14 : 14.r),
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
                width: desktop ? 36 : 36.w,
                height: desktop ? 36 : 36.h,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(desktop ? 10 : 10.r),
                ),
                child: Icon(icon, color: iconColor, size: desktop ? 18 : 18.sp),
              ),
              desktop ? const SizedBox(width: 10) : setWidth(width: 10),
              Text(
                title,
                style: CustomTextStyle.customPoppin(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          desktop ? const SizedBox(height: 14) : setHeight(height: 14),
          ...children,
        ],
      ),
    );
  }
}

// ── Mock Payment Card ────────────────────────────────────────────────────────
class _MockPaymentCard extends StatelessWidget {
  final String bankName;
  final String holderName;
  final String upiId;

  const _MockPaymentCard({
    required this.bankName,
    required this.holderName,
    required this.upiId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bankName.isEmpty ? 'BANK NAME' : bankName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                CupertinoIcons.creditcard,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                holderName.isEmpty
                    ? 'ACCOUNT HOLDER'
                    : holderName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                upiId.isEmpty ? 'UPI: active_mode@upi' : 'UPI ID: $upiId',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
