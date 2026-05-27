import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/keys/keys.dart';
import 'package:inventory/module/order_complete/controller/order_controller.dart';
import 'package:inventory/module/order_complete/widget/customer_details_mobile.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';
import '../../../common_widget/common_bottom_sheet.dart';
import '../../../helper/helper.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      isleadingButtonRequired: false,
      appBarLabel: '',
      backgroundColor: const Color(0xFFF8F8F8),
      body: Obx(
        () =>
            controller.isInvoiceLoading.value
                ? CommonProgressBar(color: AppColors.blackColor)
                : SingleChildScrollView(
                  padding:
                      SymmetricPadding(
                        horizontal: 20,
                        vertical: 24,
                      ).getPadding(),
                  child: Column(
                    children: [
                      _SuccessHero(controller: controller),
                      setHeight(height: 24),
                      _InvoiceSummaryCard(controller: controller),
                      setHeight(height: 16),

                      // ── Credit warning banner ──────────────────────────
                      Obx(
                        () =>
                            controller.isCreditSale.value
                                ? _CreditWarningBanner(
                                  onTap: () => _showAddCustomerSheet(context),
                                )
                                : const SizedBox.shrink(),
                      ),

                      Obx(
                        () => SizedBox(
                          height: controller.isCreditSale.value ? 12.h : 4.h,
                        ),
                      ),

                      _AddCustomerButton(
                        onTap: () => _showAddCustomerSheet(context),
                      ),
                      setHeight(height: 16),
                      Obx(
                        () =>
                            controller.homeButtonVisible.value
                                ? _ActionButtons(controller: controller)
                                : const SizedBox.shrink(),
                      ),
                      setHeight(height: 32),
                      _ThankYouSection(),
                      setHeight(height: 40),
                    ],
                  ),
                ),
      ),
    );
  }

  void _showAddCustomerSheet(BuildContext context) {
    commonBottomSheet(
      label: addCustomer,
      onPressed: () {
        controller.clear();
        Get.back();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: inventoryScanKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.deepPurple.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.deepPurple.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.person_add_solid,
                      size: 18.sp,
                      color: AppColors.deepPurple,
                    ),
                    setWidth(width: 10),
                    Expanded(
                      child: Text(
                        'Link this sale to a customer for credit tracking',
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 12,
                          color: AppColors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              setHeight(height: 14),
              CustomerDetailsMobileAutoCompleteWidget(controller: controller),
              setHeight(height: 10),
              CommonTextField(
                hintText: 'Full name',
                label: 'Name',
                controller: controller.name,
                validator: (add) {
                  if (add?.isEmpty ?? false) return 'Enter name';
                  return null;
                },
              ),
              setHeight(height: 10),
              CommonTextField(
                astraIsRequred: false,
                hintText: 'Street, City',
                label: 'Address',
                controller: controller.address,
              ),
              setHeight(height: 10),
              CommonTextField(
                astraIsRequred: false,
                hintText: 'Optional note',
                label: 'Description',
                controller: controller.description,
              ),
              setHeight(height: 20),
              Obx(
                () => CommonButton(
                  isLoading: controller.saveCustomerWithInvoiceLoading.value,
                  label: 'Save & Print Invoice',
                  onTap: () async {
                    if (inventoryScanKey.currentState!.validate()) {
                      final body = {
                        "sale_id": controller.invoiceData.value?.saleId ?? '',
                        'mobile_no': controller.mobileNumber.text,
                        'name': controller.name.text,
                        'address': controller.address.text,
                        'description': controller.description.text,
                      };
                      await controller.saveCustomerWithInvoice(body: body);
                      controller.homeButtonVisible.value = true;
                      final invoice = controller.invoiceData.value;
                      if (invoice != null) {
                        AppRoutes.navigateRoutes(
                          routeName: AppRouteName.invoicePrintView,
                          data: invoice,
                        );
                      }
                    }
                  },
                ),
              ),
              setHeight(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Success Hero ──────────────────────────────────────────────────────────────
class _SuccessHero extends StatelessWidget {
  final OrderController controller;
  const _SuccessHero({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.blackColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Container(
            width: 72.w,
            height: 72.h,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: Colors.green.shade400,
              size: 40.sp,
            ),
          ),
          setHeight(height: 16),
          Text(
            'Order Completed!',
            style: CustomTextStyle.customPoppin(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          setHeight(height: 6),
          Obx(
            () => Text(
              controller.invoiceData.value?.dateTime ?? '',
              style: CustomTextStyle.customOpenSans(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Invoice Summary Card ──────────────────────────────────────────────────────
class _InvoiceSummaryCard extends StatelessWidget {
  final OrderController controller;
  const _InvoiceSummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: CustomTextStyle.customOpenSans(
                  fontSize: 13,
                  color: AppColors.greyColor,
                ),
              ),
              Obx(
                () => Text(
                  '₹ ${controller.invoiceData.value?.finalAmount ?? '—'}',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
            ],
          ),
          setHeight(height: 12),
          Divider(height: 1, color: Colors.grey.shade100),
          setHeight(height: 12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      size: 12.sp,
                      color: Colors.green.shade600,
                    ),
                    setWidth(width: 4),
                    Text(
                      'Payment Received',
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add Customer Button ───────────────────────────────────────────────────────
class _AddCustomerButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCustomerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.deepPurple.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.deepPurple.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: AppColors.deepPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                CupertinoIcons.person_add_solid,
                size: 18.sp,
                color: AppColors.deepPurple,
              ),
            ),
            setWidth(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Customer',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepPurple,
                    ),
                  ),
                  Text(
                    'Link this sale for credit tracking',
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 11,
                      color: AppColors.deepPurple.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16.sp,
              color: AppColors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action Buttons ────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final OrderController controller;
  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap:
                () => AppRoutes.navigateRoutes(
                  routeName: AppRouteName.bottomNavigation,
                ),
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.house_fill,
                    size: 18.sp,
                    color: AppColors.blackColor,
                  ),
                  setWidth(width: 8),
                  Text(
                    'Home',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        setWidth(width: 12),
        Expanded(
          child: Obx(
            () => InkWell(
              onTap: () {
                final invoice = controller.invoiceData.value;
                if (invoice != null) {
                  AppRoutes.navigateRoutes(
                    routeName: AppRouteName.invoicePrintView,
                    data: invoice,
                  );
                } else if (controller.isInvoiceLoading.value) {
                  showSnackBar(error: 'Invoice is loading, please wait...');
                } else {
                  showSnackBar(error: 'Invoice not available');
                }
              },
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.blackColor,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child:
                    controller.isInvoiceLoading.value
                        ? Center(
                          child: SizedBox(
                            width: 18.w,
                            height: 18.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.printer_fill,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                            setWidth(width: 8),
                            Text(
                              'Print Invoice',
                              style: CustomTextStyle.customPoppin(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Thank You Section ─────────────────────────────────────────────────────────
class _ThankYouSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🙏 Thank you for choosing',
            style: CustomTextStyle.customOpenSans(
              fontSize: 14,
              color: AppColors.greyColor,
            ),
            textAlign: TextAlign.center,
          ),
          setHeight(height: 4),
          Text(
            'Hisab Box',
            style: CustomTextStyle.customPoppin(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.blackColor,
            ),
          ),
          setHeight(height: 6),
          Text(
            'Smart billing & inventory for every business',
            style: CustomTextStyle.customOpenSans(
              fontSize: 12,
              color: AppColors.greyColor,
            ),
            textAlign: TextAlign.center,
          ),
          setHeight(height: 16),
          Divider(height: 1, color: Colors.grey.shade100),
          setHeight(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _FeaturePill(
                icon: CupertinoIcons.chart_bar_fill,
                label: 'Smart Reports',
                color: Color(0xFF1565C0),
              ),
              _FeaturePill(
                icon: CupertinoIcons.barcode_viewfinder,
                label: 'Barcode Scanning',
                color: Color(0xFF2E7D32),
              ),
              _FeaturePill(
                icon: CupertinoIcons.printer_fill,
                label: 'Instant Invoices',
                color: Color(0xFF6A1B9A),
              ),
              _FeaturePill(
                icon: CupertinoIcons.cube_box_fill,
                label: 'Inventory Tracking',
                color: Color(0xFFE65100),
              ),
              _FeaturePill(
                icon: CupertinoIcons.person_2_fill,
                label: 'Customer Credits',
                color: Color(0xFFC62828),
              ),
              _FeaturePill(
                icon: CupertinoIcons.lock_shield_fill,
                label: 'Secure & Reliable',
                color: Color(0xFF37474F),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Credit Warning Banner ─────────────────────────────────────────────────────
class _CreditWarningBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _CreditWarningBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
      ),
      child: Column(
        children: [
          // ── Header strip ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: Colors.white,
                  size: 16.sp,
                ),
                setWidth(width: 8),
                Text(
                  'Action Required — Credit Sale',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This sale includes a credit payment. You must add the customer details before you can proceed.',
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 13,
                    color: const Color(0xFF7B4F00),
                  ),
                ),
                setHeight(height: 12),
                _step(number: '1', text: 'Tap "Add Customer" below'),
                setHeight(height: 6),
                _step(
                  number: '2',
                  text: 'Enter customer mobile, name & address',
                ),
                setHeight(height: 6),
                _step(
                  number: '3',
                  text: 'Tap "Save & Print Invoice" to unlock Home & Print',
                ),
                setHeight(height: 14),

                // SizedBox(
                //   width: double.infinity,
                //   child: GestureDetector(
                //     onTap: null,
                //     child: Container(
                //       padding: EdgeInsets.symmetric(vertical: 11.h),
                //       decoration: BoxDecoration(
                //         color: const Color(0xFFFF9800),
                //         borderRadius: BorderRadius.circular(10.r),
                //       ),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Icon(
                //             CupertinoIcons.person_add_solid,
                //             color: Colors.white,
                //             size: 16.sp,
                //           ),
                //           setWidth(width: 8),
                //           Text(
                //             'Add Customer Now',
                //             style: CustomTextStyle.customPoppin(
                //               fontSize: 13,
                //               fontWeight: FontWeight.w700,
                //               color: Colors.white,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _step({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.w,
          height: 20.h,
          decoration: const BoxDecoration(
            color: Color(0xFFFF9800),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: CustomTextStyle.customPoppin(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        setWidth(width: 8),
        Expanded(
          child: Text(
            text,
            style: CustomTextStyle.customOpenSans(
              fontSize: 12,
              color: const Color(0xFF7B4F00),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Feature Pill ──────────────────────────────────────────────────────────────
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          setWidth(width: 5),
          Text(
            label,
            style: CustomTextStyle.customOpenSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
