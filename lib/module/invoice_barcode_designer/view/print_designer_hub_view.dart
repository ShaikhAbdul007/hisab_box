import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';

class PrintDesignerHubView extends StatelessWidget {
  const PrintDesignerHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Print Designer',
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customize your prints',
              style: CustomTextStyle.customNato(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            setHeight(height: 20),
            _DesignerCard(
              icon: CupertinoIcons.barcode,
              title: 'Barcode Label Designer',
              subtitle: 'Drag & drop elements on thermal paper canvas',
              color: const Color(0xFF1565C0),
              onTap:
                  () => AppRoutes.navigateRoutes(
                    routeName: AppRouteName.barcodeLabelDesigner,
                  ),
            ),
            setHeight(height: 14),
            _DesignerCard(
              icon: CupertinoIcons.doc_text,
              title: 'Invoice Designer',
              subtitle: 'Choose templates and customize invoice layout',
              color: const Color(0xFF00838F),
              onTap:
                  () => AppRoutes.navigateRoutes(
                    routeName: AppRouteName.invoiceDesigner,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesignerCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DesignerCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CustomTextStyle.customNato(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: CustomTextStyle.customNato(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: Colors.grey.shade400,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
