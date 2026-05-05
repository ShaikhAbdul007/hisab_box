import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../helper/app_message.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Privacy Policy',
      body: ListView(
        padding: SymmetricPadding(horizontal: 16, vertical: 16).getPadding(),
        children: [
          // ── Hero header ──────────────────────────────────────────────
          _PolicyHero(
            icon: CupertinoIcons.lock_shield_fill,
            iconColor: const Color(0xFF1565C0),
            title: 'Privacy Policy',
            subtitle: 'Hisab Box — Billing & Inventory App',
            description:
                'Your privacy is important to us. This policy explains how we collect, use, and protect your data.',
          ),
          setHeight(height: 20),

          _Section(
            number: '1',
            title: 'Information We Collect',
            color: const Color(0xFF1565C0),
            children: [
              _SubHeading('1.1 Personal Information (Optional)'),
              _Body(
                'We may collect the following only when you provide it:\n• Name\n• Email ID\n• Phone number\n• Business / shop details\n\nWe do NOT collect any personal information without your input.',
              ),
            ],
          ),

          _Section(
            number: '2',
            title: 'Transaction & App Usage Data',
            color: const Color(0xFF2E7D32),
            children: [
              _Body(
                'Our app may collect:\n• Product details (name, price, stock)\n• Sales records & invoices\n• Payment details (Cash / UPI / Card / Credit)\n• Customer details (if entered)\n• Device information (for crash logs & analytics)\n\nThis data is used only to improve app features.',
              ),
            ],
          ),

          _Section(
            number: '3',
            title: 'Camera & Storage Permissions',
            color: const Color(0xFFE65100),
            children: [
              _Body(
                '• Camera → for barcode scanning\n• Storage → to save invoices or import/export inventory\n\nThese permissions are used ONLY for app functions.',
              ),
            ],
          ),

          _Section(
            number: '4',
            title: 'How We Use Your Data',
            color: const Color(0xFF6A1B9A),
            children: [
              _Body(
                '• Generating invoices\n• Managing inventory & sales history\n• App analytics\n• User support\n• Cloud backup (if enabled)\n\nWe never sell your data.',
              ),
            ],
          ),

          _Section(
            number: '5',
            title: 'Data Storage & Security',
            color: const Color(0xFF00695C),
            children: [
              _Body(
                '• Encrypted databases\n• Secure cloud storage\n• No unauthorized access\n\nYour data remains yours.',
              ),
            ],
          ),

          _Section(
            number: '6',
            title: 'Third-Party Services',
            color: const Color(0xFF37474F),
            children: [
              _Body(
                '• Google Firebase (Authentication, DB, Crash Analytics)\n• Payment SDKs (if enabled)',
              ),
            ],
          ),

          _Section(
            number: '7',
            title: "Children's Privacy",
            color: const Color(0xFFC62828),
            children: [
              _Body(
                'We do not knowingly collect information from children under 13.',
              ),
            ],
          ),

          _Section(
            number: '8',
            title: 'Data Deletion Request',
            color: const Color(0xFF1565C0),
            children: [
              _Body(
                'Users can request account or data deletion.\nEmail: 📩 $customerCareEmail',
              ),
            ],
          ),

          _Section(
            number: '9',
            title: 'Changes to This Policy',
            color: const Color(0xFF37474F),
            children: [_Body('We may update this policy occasionally.')],
          ),

          _Section(
            number: '10',
            title: 'Contact Us',
            color: const Color(0xFF2E7D32),
            children: [_Body('Email: 📩 $customerCareEmail')],
          ),

          setHeight(height: 30),
        ],
      ),
    );
  }
}

// ── Privacy Policy & T&C shared widgets ──────────────────────────────────────

class _PolicyHero extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String description;

  const _PolicyHero({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52.w,
            height: 52.h,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: iconColor, size: 26.sp),
          ),
          setHeight(height: 12),
          Text(
            title,
            style: CustomTextStyle.customPoppin(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          setHeight(height: 2),
          Text(
            subtitle,
            style: CustomTextStyle.customOpenSans(
              fontSize: 12,
              color: AppColors.greyColor,
            ),
          ),
          setHeight(height: 10),
          Text(
            description,
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

class _Section extends StatelessWidget {
  final String number;
  final String title;
  final Color color;
  final List<Widget> children;

  const _Section({
    required this.number,
    required this.title,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
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
                width: 30.w,
                height: 30.h,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: CustomTextStyle.customPoppin(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ),
              setWidth(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: CustomTextStyle.customPoppin(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          setHeight(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _SubHeading extends StatelessWidget {
  final String text;
  const _SubHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: CustomTextStyle.customPoppin(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: CustomTextStyle.customOpenSans(
        fontSize: 13,
        color: const Color(0xFF444444),
      ),
    );
  }
}
