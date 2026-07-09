import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';
import 'package:inventory/module/credits_amount/model/credit_model.dart';
import 'package:inventory/module/credits_amount/model/credit_customer_details_model.dart';
import 'package:inventory/module/credits_amount/controller/credit_controller.dart';

class CreditPaymentView extends StatefulWidget {
  const CreditPaymentView({super.key});

  @override
  State<CreditPaymentView> createState() => _CreditPaymentViewState();
}

class _CreditPaymentViewState extends State<CreditPaymentView> {
  final controller = Get.find<CredtiController>();
  bool paymentMade = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = Get.arguments as CreditDataItem;
      if (arguments.customerId != null) {
        controller.fetchCustomerCreditDetails(arguments.customerId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as CreditDataItem;
    final customerName = arguments.nameOfCustomer ?? '';
    final customerMobile = arguments.mobileNo?.toString() ?? '';
    final customerAddress = arguments.customer?.address?.toString() ?? '';

    return CommonAppbar(
      appBarLabel: 'Credit Ledger Details',

      body: Obx(() {
        if (controller.isDetailsLoading.value) {
          return const Center(
            child: CommonProgressBar(color: AppColors.blackColor),
          );
        }

        final details = controller.creditCustomerDetails.value;
        final summary = details?.summary;
        final allTransactions = details?.transactions ?? [];
        final transactions =
            allTransactions.where((tx) {
              final paidAmt = double.tryParse(tx.paidAmount ?? '0') ?? 0.0;
              return paidAmt > 0;
            }).toList();

        // Check if there is any pending amount
        final totalPending =
            double.tryParse(summary?.totalPending ?? '0') ?? 0.0;
        final hasPending = totalPending > 0;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                children: [
                  // ── Customer Profile Card ─────────────────────────────
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24.r,
                              backgroundColor: AppColors.deepPurple.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                CupertinoIcons.person_fill,
                                color: AppColors.deepPurple,
                                size: 24.sp,
                              ),
                            ),
                            setWidth(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customerName.isNotEmpty
                                        ? customerName
                                        : 'Unknown Customer',
                                    style: CustomTextStyle.customPoppin(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (customerMobile.isNotEmpty) ...[
                                    setHeight(height: 3),
                                    Text(
                                      customerMobile,
                                      style: CustomTextStyle.customOpenSans(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                  if (customerAddress.isNotEmpty) ...[
                                    setHeight(height: 3),
                                    Text(
                                      customerAddress,
                                      style: CustomTextStyle.customOpenSans(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Show Bill Details & Credit date inside the customer card!
                        if (arguments.billNo != null ||
                            arguments.dateOfCredit != null) ...[
                          const Divider(height: 20, thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bill Number',
                                    style: CustomTextStyle.customOpenSans(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  setHeight(height: 2),
                                  Text(
                                    arguments.billNo?.isNotEmpty == true
                                        ? arguments.billNo!
                                        : 'N/A',
                                    style: CustomTextStyle.customPoppin(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Credit Date & Time',
                                    style: CustomTextStyle.customOpenSans(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  setHeight(height: 2),
                                  Text(
                                    arguments.dateOfCredit?.isNotEmpty == true
                                        ? '${formatDateTime(arguments.dateOfCredit!)} ${formatDateTime(showTime: true, showDate: false, arguments.dateOfCredit!)}'
                                        : 'N/A',
                                    style: CustomTextStyle.customPoppin(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  setHeight(height: 14),

                  // ── Ledger Summary Card (Total Credit, Paid, Pending) ───────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total Credit',
                          value: '₹${summary?.totalCredit ?? 0}',
                          color: const Color(0xFF1565C0),
                        ),
                      ),
                      setWidth(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Total Paid',
                          value: '₹${summary?.totalPaid ?? 0}',
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      setWidth(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Remaining',
                          value: '₹${summary?.totalPending ?? 0}',
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                  setHeight(height: 18),

                  // ── Transaction Details List Header ─────────────────────────────
                  Text(
                    'Transaction History',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  setHeight(height: 10),

                  if (transactions.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: const CommonNoDataFound(
                        message: 'No transactions found',
                      ),
                    )
                  else
                    ...transactions.map((tx) => _TransactionCard(tx: tx)),
                ],
              ),
            ),

            // ── Bottom Pay Button ──────────────────────────────────────────
            if (hasPending)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: CommonButton(
                  label: 'Pay Remaining (₹$totalPending)',
                  onTap: () async {
                    arguments.remainingAmount = totalPending.toString();
                    // Navigate to confirm view which has payment method split controllers
                    var res = await Get.toNamed(
                      AppRouteName.creditPaymentConfirmView,
                      arguments: arguments,
                    );
                    if (res == true) {
                      paymentMade = true;
                      if (arguments.customerId != null) {
                        controller.fetchCustomerCreditDetails(
                          arguments.customerId!,
                        );
                      }
                    }
                  },
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: CustomTextStyle.customOpenSans(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          setHeight(height: 4),
          Text(
            value,
            style: CustomTextStyle.customPoppin(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final CreditCustomerTransaction tx;

  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: const Color(0xFFE8F5E9),
            child: Icon(
              CupertinoIcons.checkmark_seal_fill,
              color: const Color(0xFF2E7D32),
              size: 18.sp,
            ),
          ),
          setWidth(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Received',
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                setHeight(height: 2),
                Text(
                  '₹${tx.paidAmount ?? "0.0"}',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          if (tx.updatedAt != null && tx.updatedAt!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatDateTime(tx.updatedAt!),
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                setHeight(height: 2),
                Text(
                  formatDateTime(
                    showTime: true,
                    showDate: false,
                    tx.updatedAt!,
                  ),
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
