import 'package:flutter/cupertino.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_padding.dart';

import '../../helper/app_message.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Privacy Policy',
      body: ListView(
        padding: AllPadding(all: 16).getPadding(),
        children: [
          Text(
            'Hisab Box (Billing & Inventory App)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          Text(
            'Your privacy is important to us. This Privacy Policy explains how Hisab Box (“we”, “our”, “us”) collects, uses, stores and protects user data. By using our app, you agree to the practices described in this policy.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Text(
            '1. Information We Collect',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '1.1 Personal Information (Optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            'We may collect the following personal information only when the user provides it:\n• Name\n• Email ID\n• Phone number\n• Business/shop details\nWe DO NOT collect any personal information without user input.',
          ),

          SizedBox(height: 20),
          Text(
            '2. Transaction & App Usage Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Our app may collect:\n• Product details (name, price, stock etc.)\n• Sales records & invoices\n• Payment details (Cash/UPI/Card/Credit amounts)\n• Customer details (if entered)\n• Device information (for crash logs & analytics)\nThis data is used only to improve app features.',
          ),

          SizedBox(height: 20),
          Text(
            '3. Camera & Storage Permissions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Camera → for barcode scanning\nStorage → to save invoices or import/export inventory\nThese permissions are used ONLY for app functions.',
          ),

          SizedBox(height: 20),
          Text(
            '4. How We Use Your Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '• Generating invoices\n• Managing inventory & sales history\n• App analytics\n• User support\n• Cloud backup (if enabled)\nWe never sell your data.',
          ),

          SizedBox(height: 20),
          Text(
            '5. Data Storage & Security',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '• Encrypted databases\n• Secure cloud storage\n• No unauthorized access\nYour data remains yours.',
          ),

          SizedBox(height: 20),
          Text(
            '6. Third-Party Services',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '• Google Firebase (Authentication, DB, Crash Analytics)\n• Payment SDKs (if enabled)',
          ),

          SizedBox(height: 20),
          Text(
            '7. Children’s Privacy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'We do not knowingly collect information from children under 13.',
          ),

          SizedBox(height: 20),
          Text(
            '8. Data Deletion Request',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Users can request account or data deletion.\nEmail: 📩 $customerCareEmail',
          ),

          SizedBox(height: 20),
          Text(
            '9. Changes to This Policy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('We may update this policy occasionally.'),

          SizedBox(height: 20),
          Text(
            '10. Contact Us',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('Email: 📩 $customerCareEmail'),
        ],
      ),
    );
  }
}
