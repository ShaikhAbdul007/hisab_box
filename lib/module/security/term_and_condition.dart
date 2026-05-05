import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../helper/app_message.dart';

class TermAndCondition extends StatelessWidget {
  const TermAndCondition({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Terms & Conditions',
      body: ListView(
        padding: SymmetricPadding(horizontal: 16, vertical: 16).getPadding(),
        children: [
          // ── Hero header ──────────────────────────────────────────────
          _PolicyHero(
            icon: CupertinoIcons.doc_text_fill,
            iconColor: const Color(0xFF37474F),
            title: 'Terms & Conditions',
            subtitle: 'Hisab Box — Billing & Inventory App',
            description:
                'By downloading or using this app, you agree to the following terms. Please read them carefully.',
          ),
          setHeight(height: 20),

          _Section(
            number: '1',
            title: 'Acceptance of Terms',
            color: const Color(0xFF1565C0),
            children: [
              _Body(
                '• You have read and understood these Terms.\n• You accept and will follow all guidelines mentioned.\n\nIf you do not agree, please do not use the app.',
              ),
            ],
          ),

          _Section(
            number: '2',
            title: 'App Usage',
            color: const Color(0xFF2E7D32),
            children: [
              _Body(
                'Hisab Box is a billing, inventory & business management application. You agree to use the app only for lawful business purposes.\n\n• Do not use the app for fraudulent activities.\n• Do not interfere with app functioning.\n• Do not reverse engineer, copy, or modify the app.\n• Do not upload illegal or harmful data.',
              ),
            ],
          ),

          _Section(
            number: '3',
            title: 'User Responsibility',
            color: const Color(0xFFE65100),
            children: [
              _Body(
                '• Accuracy of data entered is your responsibility.\n• You must manage your inventory, sales, and customer details.\n• Keep your login details secure.\n\nWe are not responsible for incorrect data entered by the user.',
              ),
            ],
          ),

          _Section(
            number: '4',
            title: 'Data & Privacy',
            color: const Color(0xFF6A1B9A),
            children: [
              _Body(
                'Your data is protected as per our Privacy Policy. We do not sell or misuse your data.\n\n• You must back up your data (if using offline mode).\n• Enable cloud backup if you want online storage.',
              ),
            ],
          ),

          _Section(
            number: '5',
            title: 'Subscription / Charges',
            color: const Color(0xFF00695C),
            children: [
              _Body(
                '• Prices may change with notice.\n• Payments handled by Play Store / third-party gateway.\n• No external/manual payments accepted unless officially authorized.',
              ),
            ],
          ),

          _Section(
            number: '6',
            title: 'Third-Party Integrations',
            color: const Color(0xFF37474F),
            children: [
              _Body(
                'The app may use:\n• Firebase\n• Payment SDKs\n• Barcode scanning libraries\n\nYou agree to follow their terms while using these services.',
              ),
            ],
          ),

          _Section(
            number: '7',
            title: 'Limitations of Liability',
            color: const Color(0xFFC62828),
            children: [
              _Body(
                'We try to provide a stable experience, but we are not liable for:\n• Loss of business data\n• Wrong billing due to incorrect entries\n• Device issues, crashes, or data corruption\n• Network failures or server downtime\n\nYou use the app at your own risk.',
              ),
            ],
          ),

          _Section(
            number: '8',
            title: 'Intellectual Property',
            color: const Color(0xFF1565C0),
            children: [
              _Body(
                'The app design, code, logo, and features belong to Software Snip / Hisab Box. You may not copy, redistribute, or sell any part of the app.',
              ),
            ],
          ),

          _Section(
            number: '9',
            title: 'Termination of Usage',
            color: const Color(0xFFC62828),
            children: [
              _Body(
                'We may restrict or suspend your access if:\n• You misuse the app\n• You violate these terms\n• You engage in illegal activity',
              ),
            ],
          ),

          _Section(
            number: '10',
            title: 'Updates & Changes',
            color: const Color(0xFF37474F),
            children: [
              _Body(
                'We may update app features, pricing, Privacy Policy, or Terms & Conditions. Continued use means you accept the updated terms.',
              ),
            ],
          ),

          _Section(
            number: '11',
            title: 'Contact Us',
            color: const Color(0xFF2E7D32),
            children: [
              _Body(
                'For support or legal queries, contact:\nEmail: 📩 $customerCareEmail',
              ),
            ],
          ),

          setHeight(height: 30),
        ],
      ),
    );
  }
}

// ── Shared widgets (same as privacy_policy.dart) ──────────────────────────────

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
