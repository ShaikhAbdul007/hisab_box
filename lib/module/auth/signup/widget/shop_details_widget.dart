import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:inventory/common_widget/common_padding.dart';

import '../../../../common_widget/size.dart';
import '../../../../common_widget/textfiled.dart';
import '../../../../helper/app_message.dart';

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
      children: [
        /// Email
        CommonTextField(
          hintText: 'Email',
          label: 'Email',
          controller: email,
          marginPadding: SymmetricPadding(horizontal: 5).getPadding(),
          suffixIcon: commonSuffixIcon(
            child: const Icon(CupertinoIcons.mail, size: 18),
          ),
          validator: (emailValue) {
            if (emailValue!.isEmpty) return emptyEmail;
            if (!GetUtils.isEmail(emailValue)) return invalidEmail;
            return null;
          },
        ),

        setHeight(height: 5),

        /// Mobile No
        CommonTextField(
          hintText: 'Mobile No',
          label: 'Mobile No',
          controller: mobileNo,
          inputLength: 10,
          keyboardType: TextInputType.number,
          marginPadding: SymmetricPadding(horizontal: 5).getPadding(),
          suffixIcon: commonSuffixIcon(
            child: const Icon(CupertinoIcons.phone, size: 18),
          ),
          validator: (value) {
            if (value!.isEmpty) return emptyMobileNo;
            if (value.length < 10) return shortPassword;
            return null;
          },
        ),

        setHeight(height: 5),

        /// Alternate Mobile No
        CommonTextField(
          hintText: 'Alternate No',
          label: 'Alternate No',
          controller: alternateMobileNo,
          keyboardType: TextInputType.number,
          inputLength: 10,
          marginPadding: SymmetricPadding(horizontal: 5).getPadding(),
          suffixIcon: commonSuffixIcon(
            child: const Icon(CupertinoIcons.phone, size: 18),
          ),
        ),

        setHeight(height: 5),

        /// Password
        CommonTextField(
          hintText: 'Password',
          label: 'Password',
          controller: password,
          obscureText: true,
          marginPadding: SymmetricPadding(horizontal: 5).getPadding(),
          suffixIcon: commonSuffixIcon(
            child: const Icon(CupertinoIcons.padlock, size: 18),
          ),
          validator: (value) {
            if (value!.isEmpty) return emptyPassword;
            if (value.length < 6) return shortPassword;
            return null;
          },
        ),

        setHeight(height: 5),

        /// Confirm Password (toggle)
        CommonTextField(
          hintText: 'Confirm Password',
          label: 'Confirm Password',
          controller: confirmpassword,
          obscureText: obscureText,
          marginPadding: SymmetricPadding(horizontal: 5).getPadding(),
          suffixIcon: commonSuffixIcon(
            child: InkWell(
              onTap: onTap,
              child: Icon(
                obscureText ? CupertinoIcons.padlock : CupertinoIcons.lock_open,
                size: 18,
              ),
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) return emptyPassword;
            if (value.length < 6) return shortPassword;
            if (password.text != confirmpassword.text) {
              return passwordMismatch;
            }
            return null;
          },
        ),
      ],
    );
  }
}
