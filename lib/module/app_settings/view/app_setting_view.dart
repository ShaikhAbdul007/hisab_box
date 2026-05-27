import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/app_settings/controller/app_setting_controller.dart';
import 'package:inventory/module/invoice/widget/bluetooth_validate_widget.dart';

class AppSettingView extends GetView<AppSettingController> {
  const AppSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'App Settings',
      body: ListView(
        padding: SymmetricPadding(horizontal: 16, vertical: 16).getPadding(),
        children: [
          // ── Scanner & Godown ─────────────────────────────────────────
          _SectionLabel(label: 'Features'),
          setHeight(height: 8),
          Container(
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
              children: [
                Obx(
                  () => _ToggleTile(
                    icon: CupertinoIcons.barcode_viewfinder,
                    iconColor: const Color(0xFF1565C0),
                    title: 'Inventory Scan',
                    subtitle: 'Enable barcode scanner for inventory',
                    value: controller.isInventoryScanSelected.value,
                    onChanged: (v) {
                      controller.isInventoryScanSelected.value = v;
                      customMessageOrErrorPrint(
                        message: controller.isInventoryScanSelected.value,
                      );
                      controller.saveInventoryScanValue(v);
                    },
                    isLast: false,
                  ),
                ),
                Divider(height: 1, indent: 68, color: Colors.grey.shade100),
                Obx(
                  () => _ToggleTile(
                    icon: CupertinoIcons.archivebox_fill,
                    iconColor: const Color(0xFF2E7D32),
                    title: 'Godown',
                    subtitle: 'Enable godown / warehouse module',
                    value: controller.isGodownSelected.value,
                    onChanged: (v) {
                      controller.isGodownSelected.value = v;
                      customMessageOrErrorPrint(
                        message: controller.isGodownSelected.value,
                      );
                      controller.saveGodownValue(v);
                    },
                    isLast: true,
                  ),
                ),
              ],
            ),
          ),
          setHeight(height: 20),
          // _SectionLabel(label: 'Margin'), setHeight(height: 8),
          // Container(
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(14.r),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withValues(alpha: 0.05),
          //         blurRadius: 8,
          //         offset: const Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: Column(
          //     children: [
          //       Row(
          //         children: [
          //           Expanded(
          //             child: CommonTextField(
          //               label: '',
          //               astraIsRequred: false,
          //               hintText: 'Enter Margin',
          //               controller: controller.profitMarginController.value,
          //               keyboardType: TextInputType.number,
          //             ),
          //           ),
          //           Container(
          //             height: 40.h,
          //             width: 40.w,
          //             margin: EdgeInsets.only(right: 10.w, top: 10.h),
          //             decoration: BoxDecoration(
          //               color:
          //                   controller
          //                           .profitMarginController
          //                           .value
          //                           .text
          //                           .isNotEmpty
          //                       ? Colors.red.shade100
          //                       : AppColors.greenColorShade100,
          //               borderRadius: BorderRadius.circular(14.r),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: Colors.black.withValues(alpha: 0.05),
          //                   blurRadius: 8,
          //                   offset: const Offset(0, 2),
          //                 ),
          //               ],
          //             ),
          //             child: Obx(
          //               () => InkWell(
          //                 onTap: () {
          //                   if (controller
          //                       .profitMarginController
          //                       .value
          //                       .text
          //                       .isNotEmpty) {
          //                     controller.saveMarginValue(
          //                       controller.profitMarginController.value.text,
          //                     );
          //                   } else {
          //                     showSnackBar(error: 'Please enter margin');
          //                   }
          //                 },
          //                 child: Icon(
          //                   controller
          //                           .profitMarginController
          //                           .value
          //                           .text
          //                           .isNotEmpty
          //                       ? CupertinoIcons.xmark_circle_fill
          //                       : CupertinoIcons.checkmark_alt,
          //                   size: 18.sp,
          //                   color:
          //                       controller
          //                               .profitMarginController
          //                               .value
          //                               .text
          //                               .isNotEmpty
          //                           ? AppColors.redColor
          //                           : const Color(0xFF2E7D32),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          // setHeight(height: 20),

          // ── Printer ──────────────────────────────────────────────────
          _SectionLabel(label: 'Printer'),
          setHeight(height: 8),
          Container(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF37474F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      CupertinoIcons.printer_fill,
                      color: const Color(0xFF37474F),
                      size: 22.sp,
                    ),
                  ),
                  setWidth(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bluetooth Printer',
                          style: CustomTextStyle.customPoppin(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Connect your receipt or label printer',
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 12,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => selectPrinter(context),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blackColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.bluetooth,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                          setWidth(width: 5),
                          Text(
                            'Connect',
                            style: CustomTextStyle.customOpenSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          setHeight(height: 20),

          // ── Info Banner ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.info_circle_fill,
                  color: Colors.blue.shade600,
                  size: 18.sp,
                ),
                setWidth(width: 10),
                Expanded(
                  child: Text(
                    'Changes take effect immediately. Restart the app if a feature does not appear.',
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> selectPrinter(BuildContext context) async {
    try {
      final device = await FlutterBluetoothPrinter.selectDevice(context);
      if (device != null) {
        controller.savePrinterAddress(device.address);
        showSnackBar(error: '✅ Printer saved: ${device.name}', isError: false);
      } else {
        commonBottomSheet(
          label: 'Bluetooth Setup',
          onPressed: () {
            controller.savePrinterAddress('');
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        color: Colors.orange.shade700,
                        size: 20.sp,
                      ),
                      setWidth(width: 10),
                      Expanded(
                        child: Text(
                          'No printer was selected. Make sure Bluetooth is on and your printer is paired.',
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 13,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                setHeight(height: 16),
                BluetoothValidateWidget(),
                setHeight(height: 30),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Printer selection failed', e, 'AppSettingView');
      showSnackBar(error: e.toString());
    }
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: CustomTextStyle.customOpenSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.greyColor,
        ),
      ),
    );
  }
}

// ── Toggle Tile ───────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          setWidth(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CustomTextStyle.customPoppin(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.blackColor,
            activeThumbColor: Colors.white,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
