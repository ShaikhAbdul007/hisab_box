import 'package:flutter/cupertino.dart';
import 'package:inventory/common_widget/common_appbar.dart';

import '../../helper/app_message.dart';

class TermAndCondition extends StatelessWidget {
  const TermAndCondition({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Terms & Conditions',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Hisab Box (Billing & Inventory App)',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const Text(
            'By downloading or using this app, you agree to the following Terms & Conditions. Please read them carefully.',
            style: TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 20),

          // 1
          _heading('1. Acceptance of Terms'),
          _text(
            '• You have read and understood these Terms.\n• You accept and will follow all guidelines mentioned.\nIf you do not agree, please do not use the app.',
          ),

          const SizedBox(height: 20),

          // 2
          _heading('2. App Usage'),
          _text(
            'Hisab Box is a billing, inventory & business management application. You agree to use the app only for lawful business purposes.',
          ),
          _text(
            '• Do not use the app for fraudulent activities.\n• Do not interfere with app functioning.\n• Do not reverse engineer, copy, or modify the app.\n• Do not upload illegal or harmful data.',
          ),

          const SizedBox(height: 20),

          // 3
          _heading('3. User Responsibility'),
          _text(
            '• Accuracy of data entered in the app is your responsibility.\n• You must manage your inventory, sales, and customer details.\n• Keep your login details secure (if using cloud backup/login).\nWe are not responsible for incorrect data entered by the user.',
          ),

          const SizedBox(height: 20),

          // 4
          _heading('4. Data & Privacy'),
          _text(
            'Your data is protected as per our Privacy Policy. We do not sell or misuse your data.',
          ),
          _text(
            '• You must back up your data (if using offline mode).\n• Enable cloud backup if you want online storage.',
          ),

          const SizedBox(height: 20),

          // 5
          _heading('5. Subscription / Charges (If applicable)'),
          _text(
            '• Prices may change with notice.\n• Payments handled by Play Store / third-party gateway.\n• No external/manual payments accepted unless officially authorized.',
          ),

          const SizedBox(height: 20),

          // 6
          _heading('6. Third-Party Integrations'),
          _text(
            'The app may use:\n• Firebase\n• Payment SDKs\n• Barcode scanning libraries\nYou agree to follow their terms while using these services.',
          ),

          const SizedBox(height: 20),

          // 7
          _heading('7. Limitations of Liability'),
          _text(
            'We try to provide a stable and error-free experience, but we are not liable for:\n• Loss of business data\n• Wrong billing due to incorrect entries\n• Device issues, crashes, or data corruption\n• Network failures or server downtime\nYou use the app at your own risk.',
          ),

          const SizedBox(height: 20),

          // 8
          _heading('8. Intellectual Property'),
          _text(
            'The app design, code, logo, and features belong to Software Snip / Hisab Box. You may not copy, redistribute, or sell any part of the app.',
          ),

          const SizedBox(height: 20),

          // 9
          _heading('9. Termination of Usage'),
          _text(
            'We may restrict or suspend your access if:\n• You misuse the app\n• You violate these terms\n• You engage in illegal activity',
          ),

          const SizedBox(height: 20),

          // 10
          _heading('10. Updates & Changes'),
          _text(
            'We may update app features, pricing, Privacy Policy, or Terms & Conditions. Continued use means you accept the updated terms.',
          ),

          const SizedBox(height: 20),

          // 11
          _heading('11. Contact Us'),
          _text('For support or legal queries, contact:'),
          _text('Email : 📩 $customerCareEmail'),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  static Widget _heading(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  static Widget _text(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(text, style: const TextStyle(fontSize: 16, height: 1.4)),
    );
  }
}
