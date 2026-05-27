import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';

class BluetoothValidateWidget extends StatelessWidget {
  const BluetoothValidateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Bluetooth icon ───────────────────────────────────────────
        Container(
          width: 64.w,
          height: 64.h,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.bluetooth,
            size: 30.sp,
            color: Colors.blue.shade600,
          ),
        ),
        setHeight(height: 16),

        // ── Title ────────────────────────────────────────────────────
        Text(
          'Bluetooth is Off',
          style: CustomTextStyle.customPoppin(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        setHeight(height: 6),

        // ── Subtitle ─────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'Please turn on Bluetooth to connect your printer.',
            style: CustomTextStyle.customOpenSans(
              fontSize: 13,
              color: AppColors.greyColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        setHeight(height: 20),

        // ── Steps ────────────────────────────────────────────────────
        _StepRow(
          step: '1',
          text: 'Open phone Settings',
          color: Colors.blue.shade600,
        ),
        setHeight(height: 8),
        _StepRow(
          step: '2',
          text: 'Enable Bluetooth',
          color: Colors.blue.shade600,
        ),
        setHeight(height: 8),
        _StepRow(
          step: '3',
          text: 'Pair your printer device',
          color: Colors.blue.shade600,
        ),
        setHeight(height: 24),

        // ── Button ───────────────────────────────────────────────────
        CommonButton(
          label: 'Open Bluetooth Settings',
          onTap: () {
            Get.back();
            AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
          },
        ),
        setHeight(height: 8),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final String step;
  final String text;
  final Color color;

  const _StepRow({required this.step, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Container(
            width: 26.w,
            height: 26.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: CustomTextStyle.customPoppin(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          setWidth(width: 12),
          Text(
            text,
            style: CustomTextStyle.customOpenSans(
              fontSize: 13,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
