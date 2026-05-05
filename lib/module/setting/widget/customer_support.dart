import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../../helper/app_message.dart';

class CustomerSupport extends StatelessWidget {
  final Function()? emailOnTap;
  final Function()? phoneOnTap;
  const CustomerSupport({super.key, this.emailOnTap, this.phoneOnTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8, 20.w, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header icon ──────────────────────────────────────────────
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: AppColors.blackColor.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 28.sp,
              color: AppColors.blackColor,
            ),
          ),
          setHeight(height: 12),
          Text(
            'We\'re here to help',
            style: CustomTextStyle.customPoppin(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          setHeight(height: 4),
          Text(
            'Reach out via phone or email',
            style: CustomTextStyle.customOpenSans(
              fontSize: 13,
              color: AppColors.greyColor,
            ),
          ),
          setHeight(height: 20),

          // ── Phone card ───────────────────────────────────────────────
          _ContactCard(
            icon: CupertinoIcons.phone_fill,
            iconColor: const Color(0xFF2E7D32),
            label: 'Phone',
            value: customerCareNumber,
            onTap: phoneOnTap,
          ),
          setHeight(height: 12),

          // ── Email card ───────────────────────────────────────────────
          _ContactCard(
            icon: CupertinoIcons.mail_solid,
            iconColor: const Color(0xFF1565C0),
            label: 'Email',
            value: customerCareEmail,
            onTap: emailOnTap,
          ),
          setHeight(height: 24),

          // ── Close button ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.blackColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(
                'Close',
                style: CustomTextStyle.customPoppin(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          setHeight(height: 30),
        ],
      ),
    );
  }
}

// ── Contact Card ──────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Function()? onTap;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: iconColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.h,
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
                    label,
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 11,
                      color: AppColors.greyColor,
                    ),
                  ),
                  setHeight(height: 2),
                  Text(
                    value,
                    style: CustomTextStyle.customPoppin(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.arrow_up_right_square_fill,
              size: 18.sp,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Kept for backward compat ──────────────────────────────────────────────────
class CustomerSupportText extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function()? onTap;
  const CustomerSupportText({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon),
          setWidth(width: 10),
          Text(label, style: CustomTextStyle.customMontserrat(fontSize: 18)),
        ],
      ),
    );
  }
}
