import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/responsive_layout/dimension.dart';
import 'package:get/get.dart';
import 'package:inventory/module/sell/widget/partialpayment_widget.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_radio_button.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/routes/routes.dart';
import '../../../common_widget/colors.dart';
import '../../../helper/app_message.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/route_name.dart';
import '../controller/sell_list_after_scan_controller.dart';
import '../widget/selling_confirmatio_list_text.dart';
import 'package:inventory/module/home/widget/manual_sell_sheet.dart';

class SellListAfterScan extends GetView<SellListAfterScanController> {
  const SellListAfterScan({super.key});

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      // Initialize payment details for desktop when building
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.openPaymentDialog(controller.finalTotal.value);
      });

      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            sellingProduct,
            style: CustomTextStyle.customNato(fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.only(right: 20),
          actions: [
            // Manual barcode scanner input for desktop
            Container(
              width: 320,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type Barcode & press Enter',
                  prefixIcon: const Icon(
                    CupertinoIcons.barcode_viewfinder,
                    color: AppColors.greyColor,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.deepPurple),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    controller.addProductByBarcodeManual(value.trim());
                  }
                },
              ),
            ),
          ],
          surfaceTintColor: AppColors.greyColorShade100,
          backgroundColor: AppColors.greyColorShade100,
        ),
        body: Obx(() {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left panel: Cart items
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Cart Items (${controller.productList.length})',
                            style: CustomTextStyle.customPoppin(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child:
                              controller.productList.isEmpty
                                  ? const Center(
                                    child: CommonNoDataFound(
                                      message:
                                          'No product added to cart. Use the search bar above to scan/type barcodes.',
                                    ),
                                  )
                                  : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    itemCount: controller.productList.length,
                                    itemBuilder: (context, index) {
                                      return SellingConfirmationListText(
                                        isLooseDiscountEnable:
                                            controller
                                                .productList[index]
                                                .stockType ==
                                            'loose',
                                        onDiscountChanged: (value) {
                                          controller
                                              .discountCalculateAsPerProduct(
                                                index,
                                              );
                                          controller
                                              .calculateTotalWithDiscount();
                                          // Update payment total in sync
                                          controller.openPaymentDialog(
                                            controller.finalTotal.value,
                                          );
                                        },
                                        dicountController:
                                            controller
                                                .perProductDiscount[index],
                                        sellingPrices: Obx(
                                          () => Text(
                                            controller.sellingPriceList[index]
                                                .toStringAsFixed(2),
                                            style: CustomTextStyle.customPoppin(
                                              color: AppColors.whiteColor,
                                            ),
                                          ),
                                        ),
                                        removeOnTap: () {
                                          controller.deleteProductFromCart(
                                            index,
                                          );
                                          controller.openPaymentDialog(
                                            controller.finalTotal.value,
                                          );
                                        },
                                        minusOnTap: () {
                                          controller.updateQuantity(
                                            false,
                                            index,
                                          );
                                          controller.openPaymentDialog(
                                            controller.finalTotal.value,
                                          );
                                        },
                                        plusOnTap: () {
                                          controller.updateQuantity(
                                            true,
                                            index,
                                          );
                                          controller.openPaymentDialog(
                                            controller.finalTotal.value,
                                          );
                                        },
                                        inventoryModel:
                                            controller.productList[index],
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Right panel: Payment details
              Container(
                width: 420,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(left: BorderSide(color: Colors.grey.shade200)),
                ),
                child:
                    controller.productList.isEmpty
                        ? const Center(
                          child: Text(
                            'Add items to cart to proceed with checkout',
                            style: TextStyle(color: AppColors.greyColor),
                          ),
                        )
                        : PartailPaymentWidget(
                          controller: controller,
                          showConfirmButton: true,
                          confirmLabel: 'Confirm POS Sale',
                        ),
              ),
            ],
          );
        }),
      );
    }

    return CommonAppbar(
      appBarLabel: sellingProduct,
      firstActionChild: InkWell(
        onTap: () => showSellOptionBottomSheet(context, isFromReview: true),
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          height: 36.h,
          width: 36.w,
          decoration: BoxDecoration(
            color: AppColors.blackColor,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            CupertinoIcons.barcode_viewfinder,
            color: Colors.white,
            size: 18.sp,
          ),
        ),
      ),
      // ── Footer ──────────────────────────────────────────────────────
      persistentFooterButtons: [
        _SellFooter(
          context: context,
          controller: controller,
          onSellTap:
              () =>
                  AppRoutes.navigateRoutes(routeName: AppRouteName.paymentView),
        ),
      ],
      // ── Product list ─────────────────────────────────────────────────
      body: Obx(
        () =>
            controller.productList.isNotEmpty
                ? ListView.builder(
                  padding:
                      SymmetricPadding(
                        horizontal: 12,
                        vertical: 8,
                      ).getPadding(),
                  itemCount: controller.productList.length,
                  itemBuilder: (context, index) {
                    return SellingConfirmationListText(
                      isLooseDiscountEnable:
                          controller.productList[index].stockType == 'loose',
                      onDiscountChanged: (value) {
                        controller.discountCalculateAsPerProduct(index);
                        controller.calculateTotalWithDiscount();
                      },
                      dicountController: controller.perProductDiscount[index],
                      sellingPrices: Obx(
                        () => Text(
                          controller.sellingPriceList[index].toStringAsFixed(2),
                          style: CustomTextStyle.customPoppin(
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                      removeOnTap: () {
                        controller.deleteProductFromCart(index);
                      },
                      minusOnTap: () {
                        controller.updateQuantity(false, index);
                      },
                      plusOnTap: () {
                        controller.updateQuantity(true, index);
                      },
                      inventoryModel: controller.productList[index],
                    );
                  },
                )
                : CommonNoDataFound(message: 'No product found for sell'),
      ),
    );
  }
}

// ── Sell Footer ───────────────────────────────────────────────────────────────
class _SellFooter extends StatelessWidget {
  final BuildContext context;
  final SellListAfterScanController controller;
  final VoidCallback onSellTap;

  const _SellFooter({
    required this.context,
    required this.controller,
    required this.onSellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Discount chips ─────────────────────────────────────────
            if (controller.discountPerProduct.value)
              _DiscountRow(controller: controller),

            // ── Price summary + Sell button ────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Price info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Original price (strikethrough)
                        Row(
                          children: [
                            Text(
                              'MRP  ',
                              style: CustomTextStyle.customOpenSans(
                                fontSize: 12,
                                color: AppColors.greyColor,
                              ),
                            ),
                            Text(
                              '₹${controller.totalAmount.value.toStringAsFixed(2)}',
                              style: CustomTextStyle.customOpenSans(
                                fontSize: 13,
                                color: AppColors.greyColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        setHeight(height: 4),
                        // Final total
                        Row(
                          children: [
                            Text(
                              'Total  ',
                              style: CustomTextStyle.customPoppin(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₹${controller.finalTotal.value.toStringAsFixed(2)}',
                              style: CustomTextStyle.customPoppin(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Sell button
                  CommonButton(
                    height: 48,
                    width: 130,
                    label: 'Sell  →',
                    onTap: onSellTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Discount row ──────────────────────────────────────────────────────────────
class _DiscountRow extends StatelessWidget {
  final SellListAfterScanController controller;
  const _DiscountRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.discountList.length,
                itemBuilder: (context, index) {
                  final list = controller.discountList[index];
                  return SizedBox(
                    width: 80.w,
                    child: Obx(
                      () => DiscountRadioButton(
                        label: list.label.toString(),
                        groupValue: controller.discountValue.value,
                        onChanged: (val) {
                          controller.discountValue.value = val ?? 0;
                          controller.isDiscountGiven.value = true;
                          controller.calculateDiscount();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Obx(
            () =>
                controller.isDiscountGiven.value
                    ? InkWell(
                      onTap: () {
                        controller.isDiscountGiven.value = false;
                        controller.discountValue.value = 0;
                        controller.discountDifferenceAmount = 0.0;
                        controller.amount.text =
                            controller.totalAmount.value.toString();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.clear,
                          size: 16.sp,
                          color: AppColors.blackColor,
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class DiscountRadioButton extends StatelessWidget {
  final String label;
  final int groupValue;
  final void Function(int?)? onChanged;
  const DiscountRadioButton({
    super.key,
    required this.label,
    required this.groupValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CommonRadioButton(
      label: label,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
