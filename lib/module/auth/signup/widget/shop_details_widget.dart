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

  double _w(double width) => ScreenUtil().screenWidth > 600 ? width : width.w;
  double _h(double height) =>
      ScreenUtil().screenWidth > 600 ? height : height.h;
  double _r(double radius) =>
      ScreenUtil().screenWidth > 600 ? radius : radius.r;
  double _sp(double sp) => ScreenUtil().screenWidth > 600 ? sp : sp.sp;

  Widget commonSuffixIcon({required Widget child}) {
    return CustomPadding(paddingOption: OnlyPadding(right: 10), child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: _h(8)),

        // ── Section label ──────────────────────────────────────────────
        _sectionLabel('Contact Information'),
        SizedBox(height: _h(12)),

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
                size: _sp(18),
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

        SizedBox(height: _h(14)),

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
                size: _sp(18),
                color: Colors.grey.shade500,
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) return emptyMobileNo;
              if (value.length < 10) return mobileLength;
              return null;
            },
          ),
        ),

        SizedBox(height: _h(14)),

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
                size: _sp(18),
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),

        SizedBox(height: _h(20)),

        // ── Info chip ──────────────────────────────────────────────────
        _infoChip(
          icon: Icons.info_outline_rounded,
          text:
              'Your contact details will be used for account verification and communication.',
        ),

        SizedBox(height: _h(8)),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: _w(3),
          height: _h(16),
          decoration: BoxDecoration(
            color: AppColors.blackColor,
            borderRadius: BorderRadius.circular(_r(2)),
          ),
        ),
        SizedBox(width: _w(8)),
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
        borderRadius: BorderRadius.circular(_r(14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_r(14)),
        child: child,
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _w(14), vertical: _h(12)),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(_r(12)),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: _sp(16), color: Colors.blue.shade400),
          SizedBox(width: _w(8)),
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
