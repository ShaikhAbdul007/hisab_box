import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/helper/textstyle.dart';
import 'colors.dart';

class CommonSearch extends StatelessWidget {
  final String label;
  final String hintText;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final TextEditingController controller;
  final bool isPaddingRequired;

  /// Optional suffix icon — if null, a plain search icon is shown.
  /// Pass an [Obx] widget here to get the reactive clear/search toggle.
  final Widget? icon;

  const CommonSearch({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.icon,
    this.onChanged,
    this.focusNode,
    this.isPaddingRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        style: CustomTextStyle.customPoppin(
          fontSize: 14,
          color: AppColors.blackColor,
        ),
        decoration: InputDecoration(
          // ── Leading search icon ──────────────────────────────────
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(
              CupertinoIcons.search,
              size: 18.sp,
              color: AppColors.greyColor,
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 44.w,
            minHeight: 44.h,
          ),

          // ── Trailing icon (clear / custom) ───────────────────────
          suffixIcon:
              icon != null
                  ? Padding(padding: EdgeInsets.only(right: 8.w), child: icon)
                  : null,
          suffixIconConstraints: BoxConstraints(
            minWidth: 40.w,
            minHeight: 40.h,
          ),

          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,

          hintText: hintText,
          hintStyle: CustomTextStyle.customOpenSans(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: Colors.grey.shade400,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
