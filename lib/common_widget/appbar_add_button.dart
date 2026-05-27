import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';

/// Modern + button used in appbars across all modules.
/// Shows a black rounded container with a white + icon.
/// Optional [label] shows a text badge next to the icon.
class AppBarAddButton extends StatelessWidget {
  final VoidCallback onTap;
  final String? tooltip;

  const AppBarAddButton({super.key, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final Widget button = InkWell(
      onTap: onTap,
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
        child: Icon(CupertinoIcons.add, color: Colors.white, size: 18.sp),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

/// Standalone floating-style add button used inside views (e.g. expenses).
class FloatingAddButton extends StatelessWidget {
  final VoidCallback? onTap;
  const FloatingAddButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        height: 40.h,
        width: 40.w,
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
        child: Icon(CupertinoIcons.add, color: Colors.white, size: 20.sp),
      ),
    );
  }
}
