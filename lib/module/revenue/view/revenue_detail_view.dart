import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_dropdown.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/module/revenue/controller/details_revenue_controller.dart';
import 'package:inventory/module/sell/model/sell_details_model.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';
import '../../../helper/helper.dart';
import '../widget/revenue_detail_text.dart';

class RevenueDetailView extends GetView<DetailsRevenueController> {
  const RevenueDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Sell Details',
      firstActionChild: Obx(
        () =>
            controller.isInvoiceLoading.value
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : InkWell(
                  onTap: () async {
                    final res = await controller.fetchInvoice(
                      invoiceNo: controller.data.billNo ?? '',
                    );
                    if (res.success == true && res.data != null) {
                      AppRoutes.navigateRoutes(
                        routeName: AppRouteName.invoicePrintView,
                        data: res.data,
                      );
                    } else {
                      showSnackBar(error: res.msg ?? somethingWentMessage);
                    }
                  },
                  child: const Icon(CupertinoIcons.printer_fill),
                ),
      ),
      body: Obx(
        () =>
            controller.isRevenueListLoading.value
                ? CommonProgressBar(color: AppColors.blackColor)
                : controller.sellDataList.isNotEmpty
                ? ListView.builder(
                  itemCount: controller.sellDataList.length,
                  itemBuilder: (context, index) {
                    final item = controller.sellDataList[index];
                    return RevenueDetailList(
                      revenueModel: item,
                      date: controller.date.value,
                      status: controller.status.value,
                      onExchangePressed:
                          () => AppRoutes.navigateRoutes(
                            routeName: AppRouteName.exchangeView,
                            data: item,
                          ),
                      onReturnPressed:
                          () => _showReturnBottomSheet(context, item),
                    );
                  },
                )
                : CommonNoDataFound(message: 'No revenue details found'),
      ),
    );
  }

  void _showReturnBottomSheet(BuildContext context, SellDetailsItems item) {
    controller.initReturnVariables();

    final double pricePerItem = double.tryParse(item.finalPrice ?? '0') ?? 0;
    final int maxQty = item.quantity ?? 1;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Return Item',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                item.productName ?? '',
                style: CustomTextStyle.customPoppin(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if ((item.barcode ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Barcode: ${item.barcode}',
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Quantity Selection Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity to Return',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.minus_circle),
                        onPressed: () {
                          if (controller.returnQty.value > 1) {
                            controller.returnQty.value--;
                          }
                        },
                      ),
                      Obx(
                        () => Text(
                          '${controller.returnQty.value}',
                          style: CustomTextStyle.customPoppin(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.plus_circle),
                        onPressed: () {
                          if (controller.returnQty.value < maxQty) {
                            controller.returnQty.value++;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Condition Dropdown
              Obx(
                () => CustomStaticDropDown(
                  listItems: const ['good', 'damaged'],
                  selectedDropDownItem: controller.returnCondition.value,
                  hintText: 'Item Condition',
                  notifyParent: (val) {
                    if (val != null) controller.returnCondition.value = val;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Reason
              CommonTextField(
                hintText: 'Enter reason (e.g. Size mismatch)',
                label: 'Reason for Return',
                controller: controller.returnReasonController,
                astraIsRequred: false,
              ),
              const SizedBox(height: 16),

              // Refund payment mode
              Text(
                'Refund Method',
                style: CustomTextStyle.customPoppin(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Obx(
                () => Row(
                  children:
                      ['Cash', 'UPI'].map((mode) {
                        final isSelected = controller.returnPaymentMode.value == mode;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(mode),
                            selected: isSelected,
                            selectedColor: AppColors.blackColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            onSelected: (_) => controller.returnPaymentMode.value = mode,
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Refund amount summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Refund Total:',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '₹${(pricePerItem * controller.returnQty.value).toStringAsFixed(2)}',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              Obx(
                () => CommonButton(
                  isLoading: controller.isReturnSaving.value,
                  label: 'Confirm Return',
                  onTap: () async {
                    await controller.submitReturn(
                      saleItemId: item.id ?? '',
                      refundAmount: pricePerItem * controller.returnQty.value,
                    );
                    Get.back(); // close bottom sheet
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
