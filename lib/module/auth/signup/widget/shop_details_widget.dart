import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/utils.dart';
import 'package:inventory/common_widget/common_padding.dart';
import '../../../../common_widget/colors.dart';
import '../../../../common_widget/textfiled.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/textstyle.dart';

class ShopDetails extends StatelessWidget {
  final TextEditingController password;
  final TextEditingController confirmpassword;
  final TextEditingController mobileNo;
  final TextEditingController alternateMobileNo;
  final TextEditingController email;
  final bool obscureText;
  final void Function()? onTap;

  const ShopDetails({
    super.key,
    required this.password,
    required this.confirmpassword,
    required this.mobileNo,
    required this.email,
    required this.alternateMobileNo,
    this.obscureText = false,
    required this.onTap,
  });

  Widget commonSuffixIcon({required Widget child}) {
    return CustomPadding(paddingOption: OnlyPadding(right: 10), child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),

        // ── Section label ──────────────────────────────────────────────
        _sectionLabel('Contact Information'),
        SizedBox(height: 12.h),

        // ── Email ──────────────────────────────────────────────────────
        _modernField(
          child: CommonTextField(
            hintText: 'Enter your email address',
            label: 'Email Address',
            controller: email,
            textCapitalization: TextCapitalization.none,
            marginPadding: EdgeInsets.zero,
            suffixIcon: commonSuffixIcon(
              child: Icon(
                CupertinoIcons.mail,
                size: 18.sp,
                color: Colors.grey.shade500,
              ),
            ),
            validator: (emailValue) {
              if (emailValue!.isEmpty) return emptyEmail;
              if (!GetUtils.isEmail(emailValue)) return invalidEmail;
              return null;
            },
          ),
        ),

        SizedBox(height: 14.h),

        // ── Mobile No ──────────────────────────────────────────────────
        _modernField(
          child: CommonTextField(
            hintText: 'Enter 10-digit mobile number',
            label: 'Mobile Number',
            controller: mobileNo,
            inputLength: 10,
            keyboardType: TextInputType.number,
            marginPadding: EdgeInsets.zero,
            suffixIcon: commonSuffixIcon(
              child: Icon(
                CupertinoIcons.phone,
                size: 18.sp,
                color: Colors.grey.shade500,
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) return emptyMobileNo;
              if (value.length < 10) return shortPassword;
              return null;
            },
          ),
        ),

        SizedBox(height: 14.h),

        // ── Alternate Mobile No ────────────────────────────────────────
        _modernField(
          child: CommonTextField(
            hintText: 'Optional alternate number',
            label: 'Alternate Number',
            controller: alternateMobileNo,
            keyboardType: TextInputType.number,
            inputLength: 10,
            marginPadding: EdgeInsets.zero,
            astraIsRequred: false,
            suffixIcon: commonSuffixIcon(
              child: Icon(
                CupertinoIcons.phone,
                size: 18.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // ── Info chip ──────────────────────────────────────────────────
        _infoChip(
          icon: Icons.info_outline_rounded,
          text:
              'Your contact details will be used for account verification and communication.',
        ),

        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: AppColors.blackColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: CustomTextStyle.customPoppin(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
      ],
    );
  }

  Widget _modernField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(14.r), child: child),
    );
  }

  Widget _infoChip({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.blue.shade400),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: CustomTextStyle.customNato(
                fontSize: 11,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
