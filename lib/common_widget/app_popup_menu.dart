import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/helper/textstyle.dart';

/// A single menu item model
class AppPopupItem<T> {
  final T value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDividerAbove;

  const AppPopupItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.isDividerAbove = false,
  });
}

/// Consistent popup menu used across the entire app.
/// Trigger button is always the ⋮ icon in a rounded container.
class AppPopupMenu<T> extends StatelessWidget {
  final List<AppPopupItem<T>> items;
  final void Function(T value) onSelected;

  const AppPopupMenu({
    super.key,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      color: Colors.white,
      position: PopupMenuPosition.under,
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      onSelected: onSelected,
      itemBuilder: (_) {
        final List<PopupMenuEntry<T>> entries = [];
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          if (item.isDividerAbove && i != 0) {
            entries.add(PopupMenuDivider(height: 1));
          }
          entries.add(
            PopupMenuItem<T>(
              value: item.value,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              child: Row(
                children: [
                  // Icon badge
                  Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(item.icon, color: item.color, size: 17.sp),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    item.label,
                    style: CustomTextStyle.customPoppin(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return entries;
      },
      // ── Trigger button ────────────────────────────────────────────────
      child: Container(
        height: 36.h,
        width: 36.w,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: AppColors.blackColor,
          size: 18.sp,
        ),
      ),
    );
  }
}
