import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_dropdown.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/revenue/controller/details_revenue_controller.dart';
import 'package:inventory/module/sell/model/sell_details_model.dart';

class ExchangeView extends GetView<DetailsRevenueController> {
  final SellDetailsItems item;

  ExchangeView({super.key, required this.item}) {
    controller.initExchangeVariables();
  }

  double get pricePerReturnItem => double.tryParse(item.finalPrice ?? '0') ?? 0;
  double get totalReturnCredit =>
      pricePerReturnItem * controller.exchangeReturnQty.value;

  double get totalNewPurchase {
    double sum = 0;
    for (var item in controller.newItems) {
      final double price = item['discounted_price'] ?? 0;
      final int q = item['qty'] ?? 0;
      sum += price * q;
    }
    return sum;
  }

  double get netDifference => totalNewPurchase - totalReturnCredit;

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Exchange Item',
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Return Item details section
            _buildReturnSummarySection(),
            SizedBox(height: 16.h),

            // Scan/Search section
            _buildScanSection(),
            SizedBox(height: 16.h),

            // Selected new items list section
            _buildNewItemsListSection(),
            SizedBox(height: 16.h),

            // Settle section
            _buildCheckoutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnSummarySection() {
    final int maxQty = item.quantity ?? 1;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.red.shade100, width: 1),
      ),
      color: Colors.red.shade50.withValues(alpha: 0.3),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.arrow_uturn_left_circle_fill,
                  color: AppColors.redColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Item Being Returned',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.redColor,
                  ),
                ),
              ],
            ),
            Divider(color: Colors.red.shade100),
            SizedBox(height: 8.h),
            Text(
              item.productName ?? '',
              style: CustomTextStyle.customPoppin(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if ((item.barcode ?? '').isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                'Barcode: ${item.barcode}',
                style: CustomTextStyle.customOpenSans(
                  fontSize: 11.sp,
                  color: AppColors.greyColor,
                ),
              ),
            ],
            SizedBox(height: 12.h),

            // Qty & Condition selects
            Row(
              children: [
                // Qty Selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Return Quantity',
                        style: CustomTextStyle.customPoppin(
                          fontSize: 11.sp,
                          color: AppColors.greyColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(CupertinoIcons.minus_circle),
                            onPressed: () {
                              if (controller.exchangeReturnQty.value > 1) {
                                controller.exchangeReturnQty.value--;
                              }
                            },
                          ),
                          Obx(
                            () => Text(
                              '${controller.exchangeReturnQty.value}',
                              style: CustomTextStyle.customPoppin(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.plus_circle),
                            onPressed: () {
                              if (controller.exchangeReturnQty.value < maxQty) {
                                controller.exchangeReturnQty.value++;
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Condition Select
                Expanded(
                  child: Obx(
                    () => CustomStaticDropDown(
                      listItems: const ['good', 'damaged'],
                      selectedDropDownItem:
                          controller.exchangeReturnCondition.value,
                      hintText: 'Item Condition',
                      notifyParent: (val) {
                        if (val != null)
                          controller.exchangeReturnCondition.value = val;
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            CommonTextField(
              hintText: 'Enter reason (e.g. Defective / Upgrade)',
              label: 'Reason for Return',
              controller: controller.exchangeReasonController,
              astraIsRequred: false,
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Credit Total:',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(
                  () => Text(
                    '₹${totalReturnCredit.toStringAsFixed(2)}',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.redColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan / Add Replacement Item',
              style: CustomTextStyle.customPoppin(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.exchangeBarcodeController,
                    decoration: InputDecoration(
                      hintText: 'Scan or type barcode',
                      prefixIcon: const Icon(CupertinoIcons.barcode),
                      suffixIcon: IconButton(
                        icon: const Icon(CupertinoIcons.camera),
                        onPressed: _openBarcodeScanner,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                    ),
                    style: TextStyle(fontSize: 12.sp),
                    onSubmitted: (val) {
                      if (val.isNotEmpty) controller.searchExchangeBarcode(val);
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Obx(
                  () => InkWell(
                    onTap:
                        controller.isProductSearching.value
                            ? null
                            : () {
                              final code =
                                  controller.exchangeBarcodeController.text
                                      .trim();
                              if (code.isNotEmpty)
                                controller.searchExchangeBarcode(code);
                            },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blackColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child:
                          controller.isProductSearching.value
                              ? SizedBox(
                                width: 14.sp,
                                height: 14.sp,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                'Search',
                                style: CustomTextStyle.customPoppin(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openBarcodeScanner() {
    final MobileScannerController scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: [BarcodeFormat.all],
    );

    Get.bottomSheet(
      Container(
        height: 400.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scan Product Barcode',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      scannerController.dispose();
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: MobileScanner(
                  controller: scannerController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? code = barcodes.first.rawValue;
                      if (code != null && code.isNotEmpty) {
                        scannerController.dispose();
                        Get.back(); // close scanner bottom sheet
                        controller.exchangeBarcodeController.text = code;
                        controller.searchExchangeBarcode(code);
                      }
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildNewItemsListSection() {
    return Obx(() {
      if (controller.newItems.isEmpty) return const SizedBox.shrink();
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Replacement Items',
                style: CustomTextStyle.customPoppin(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.newItems.length,
                itemBuilder: (context, idx) {
                  final item = controller.newItems[idx];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: CustomTextStyle.customPoppin(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '₹${item['discounted_price']} each',
                                style: CustomTextStyle.customOpenSans(
                                  fontSize: 11.sp,
                                  color: AppColors.greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(CupertinoIcons.minus_circle),
                              onPressed: () {
                                if (item['qty'] > 1) {
                                  controller.newItems[idx]['qty']--;
                                  controller.newItems.refresh();
                                } else {
                                  controller.newItems.removeAt(idx);
                                }
                              },
                            ),
                            Text(
                              '${item['qty']}',
                              style: CustomTextStyle.customPoppin(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.plus_circle),
                              onPressed: () {
                                if (item['qty'] < item['available_qty']) {
                                  controller.newItems[idx]['qty']++;
                                  controller.newItems.refresh();
                                } else {
                                  showSnackBar(
                                    error: 'Max available stock reached.',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCheckoutSection() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Returned Credit:',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 12.sp,
                    color: AppColors.greyColor,
                  ),
                ),
                Obx(
                  () => Text(
                    '-₹${totalReturnCredit.toStringAsFixed(2)}',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 13.sp,
                      color: AppColors.redColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Purchase Total:',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 12.sp,
                    color: AppColors.greyColor,
                  ),
                ),
                Obx(
                  () => Text(
                    '₹${totalNewPurchase.toStringAsFixed(2)}',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 13,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  final positive = netDifference >= 0;
                  return Text(
                    positive ? 'Customer Pays:' : 'Shop Refunds:',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          positive ? AppColors.blackColor : AppColors.redColor,
                    ),
                  );
                }),
                Obx(
                  () => Text(
                    '₹${netDifference.abs().toStringAsFixed(2)}',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          netDifference >= 0
                              ? Colors.green.shade800
                              : AppColors.redColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Difference Settle Method Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Settle Method',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(
                  () => Row(
                    children:
                        ['Cash', 'UPI'].map((mode) {
                          final isSelected =
                              controller.selectedPaymentMode.value == mode;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(
                                mode,
                                style: TextStyle(fontSize: 11.sp),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.blackColor,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              onSelected:
                                  (_) =>
                                      controller.selectedPaymentMode.value =
                                          mode,
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            Obx(
              () => CommonButton(
                isLoading: controller.isExchangeSaving.value,
                label: 'Complete Exchange',
                bgColor:
                    controller.newItems.isEmpty
                        ? Colors.grey
                        : AppColors.blackColor,
                onTap: () {
                  if (controller.newItems.isEmpty) {
                    showSnackBar(
                      error: 'Please add at least one replacement item.',
                    );
                    return;
                  }
                  controller.submitExchange(
                    saleItemId: item.id ?? '',
                    diffAmount: netDifference.abs(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
