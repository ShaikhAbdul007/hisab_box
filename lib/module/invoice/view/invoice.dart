import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/module/invoice/controller/invoice_controller.dart';
import 'package:inventory/module/invoice/model/invoice_model.dart';
import '../../../helper/helper.dart';
import '../../../helper/logger.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/route_name.dart';
import '../../../routes/routes.dart';
import '../widget/bluetooth_info_widget.dart';
import '../widget/bluetooth_validate_widget.dart';
import '../widget/invoice_printer.dart';

class InvoicePrint extends GetView<InvoiceController> {
  const InvoicePrint({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.arguments is InvoiceData passed from RevenueDetailView
    final InvoiceData invoiceData = controller.data as InvoiceData;
    // Payment type — first payment mode from list
    final String paymentMethod =
        (invoiceData.payments?.isNotEmpty == true &&
                (invoiceData.payments?.length ?? 0) > 1)
            ? 'Partial'
            : (invoiceData.payments?.isNotEmpty == true
                ? (invoiceData.payments!.first.mode ?? '')
                : '');

    return CommonAppbar(
      appBarLabel: 'Invoice',
      // ── Design button — opens Invoice Designer ────────────────────────────
      firstActionChild: IconButton(
        tooltip: 'Customize Invoice',
        icon: const Icon(CupertinoIcons.slider_horizontal_3),
        onPressed: () async {
          await AppRoutes.futureNavigationToRoute(
            routeName: AppRouteName.invoiceDesigner,
          );
          // Force InvoicePrinterView to rebuild with new config
          controller.designRefreshKey.value++;
        },
      ),
      persistentFooterButtons: [
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          child: Row(
            children: [
              // Share button
              Expanded(
                child: Obx(
                  () => GestureDetector(
                    onTap:
                        controller.isShareReceiptLoading.value
                            ? null
                            : () async {
                              await controller.shareReceiptAsPDF();
                            },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 52.h,
                      decoration: BoxDecoration(
                        color:
                            controller.isShareReceiptLoading.value
                                ? Colors.grey.shade300
                                : AppColors.deepPurple,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow:
                            controller.isShareReceiptLoading.value
                                ? []
                                : [
                                  BoxShadow(
                                    color: AppColors.deepPurple.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                      ),
                      child: Center(
                        child:
                            controller.isShareReceiptLoading.value
                                ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.share_rounded,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Share',
                                      style: CustomTextStyle.customRaleway(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Print button
              Expanded(
                child: Obx(
                  () => GestureDetector(
                    onTap:
                        controller.isPrintingLoading.value
                            ? null
                            : () async {
                              try {
                                bool checkBluetooth =
                                    await controller
                                        .checkBluetoothConnectivitys();
                                if (checkBluetooth == true) {
                                  if (controller.receiptController.value !=
                                      null) {
                                    await printReceipt(
                                      rController:
                                          controller.receiptController.value!,
                                      paymentMethod: paymentMethod,
                                    );
                                  } else {
                                    showSnackBar(
                                      error: 'Printer is not initialized yet',
                                    );
                                  }
                                } else {
                                  commonBottomSheet(
                                    label: 'Bluetooth Info',
                                    onPressed: () => Get.back(),
                                    child: BluetoothValidateWidget(),
                                  );
                                }
                              } catch (e) {
                                AppLogger.error(
                                  'Print button flow failed',
                                  e,
                                  'Invoice',
                                );
                                showSnackBar(error: e.toString());
                              }
                            },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 52.h,
                      decoration: BoxDecoration(
                        color:
                            controller.isPrintingLoading.value
                                ? Colors.grey.shade300
                                : AppColors.blackColor,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow:
                            controller.isPrintingLoading.value
                                ? []
                                : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                      ),
                      child: Center(
                        child:
                            controller.isPrintingLoading.value
                                ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.print_rounded,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Print',
                                      style: CustomTextStyle.customRaleway(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      body: Obx(() {
        // designRefreshKey read karne se Obx rebuild trigger hota hai
        final _ = controller.designRefreshKey.value;
        return InvoicePrinterView(
          printInvoiceModel: invoiceData,
          paymentMethod: paymentMethod,
          onInitialized: (p0) => controller.setReceiptController(p0),
        );
      }),
    );
  }

  Future<void> printReceipt({
    required ReceiptController rController,
    required String paymentMethod,
  }) async {
    controller.isPrintingLoading.value = true;
    try {
      final String? device = controller.retrievePrinterAddress();
      if (device == null || device.isEmpty) {
        showMessage(
          message: 'No saved printer found. Please select a printer first.',
        );
        commonBottomSheet(
          label: 'Bluetooth Info',
          onPressed: () {
            Get.back();
          },
          child: BluetoothInfoWidget(),
        );
        return;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      final res = await rController.print(address: device, delayTime: 0);
      if (res == true) {
        showSnackBar(error: 'Invoice printed successfully.');
        AppRoutes.navigateRoutes(routeName: AppRouteName.bottomNavigation);
      } else {
        showMessage(
          message: 'Print failed. Please reconnect printer and try again.',
        );
      }
    } catch (e) {
      AppLogger.error('Receipt print failed', e, 'Invoice');
      showSnackBar(error: e.toString());
    } finally {
      controller.isPrintingLoading.value = false;
    }
  }
}
