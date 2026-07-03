import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/responsive_layout/dimension.dart';

/// Shared section card used across all product form components.
class ProductFieldCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final Widget child;

  const ProductFieldCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool desktop = isDesktop(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(desktop ? 14 : 14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: desktop ? 34 : 34.w,
                height: desktop ? 34 : 34.h,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(desktop ? 9 : 9.r),
                ),
                child: Icon(icon, color: iconColor, size: desktop ? 17 : 17.sp),
              ),
              setWidth(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: CustomTextStyle.customPoppin(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          setHeight(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Shared page header used on product add/edit forms.
class ProductFormHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ProductFormHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inventory_2_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final bool desktop = isDesktop(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.blackColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(desktop ? 24 : 24.r),
          bottomRight: Radius.circular(desktop ? 24 : 24.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: desktop ? 52 : 52.w,
            height: desktop ? 52 : 52.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(desktop ? 14 : 14.r),
            ),
            child: Icon(icon, color: Colors.white, size: desktop ? 26 : 26.sp),
          ),
          setWidth(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CustomTextStyle.customPoppin(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                setHeight(height: 3),
                Text(
                  subtitle,
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
