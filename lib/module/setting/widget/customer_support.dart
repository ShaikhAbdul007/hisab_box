import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helper/app_message.dart';
import '../../../routes/route_name.dart';

import '../../../common_widget/common_button.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';

class CustomerSupport extends StatelessWidget {
  final Function()? emailOnTap;
  final Function()? phoneOnTap;
  const CustomerSupport({super.key, this.emailOnTap, this.phoneOnTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          setHeight(height: 20),
          CustomerSupportText(
            onTap: phoneOnTap,
            label: customerCareNumber,
            icon: CupertinoIcons.phone,
          ),
          setHeight(height: 30),
          CustomerSupportText(
            onTap: emailOnTap,
            label: customerCareEmail,
            icon: CupertinoIcons.mail,
          ),
          setHeight(height: 30),
          CommonButton(
            label: 'OK',
            onTap: () {
              Get.back();
            },
          ),
          setHeight(height: 50),
        ],
      ),
    );
  }
}

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
        ], //
      ),
    );
  }
}
