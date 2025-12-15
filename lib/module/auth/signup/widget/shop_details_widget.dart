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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTextField(
          hintText: 'Email',
          label: 'Email',
          controller: email,
          suffixIcon: Icon(CupertinoIcons.mail, size: 18),
          marginPadding: SymmetricPadding(horizontal: 5).getPadding(),
          validator: (emailValue) {
            if (emailValue!.isEmpty) {
              return emptyEmail;
            }
            if (!GetUtils.isEmail(emailValue)) {
              return invalidEmail;
            } else {
              return null;
            }
          },
        ),
        setHeight(height: 5),
        CommonTextField(
          hintText: 'Mobile No',
          label: 'Mobile No',
          controller: mobileNo,
          inputLength: 10,
          marginPadding: SymmetricPadding(horizontal: 5).getPadding(),
          keyboardType: TextInputType.number,
          suffixIcon: Icon(CupertinoIcons.phone, size: 18),
          validator: (mobileNo) {
            if (mobileNo!.isEmpty) {
              return emptyMobileNo;
            } else if (mobileNo.length < 10) {
              return shortPassword;
            } else {
              return null;
            }
          },
        ),
        setHeight(height: 5),
        CommonTextField(
          marginPadding: SymmetricPadding(horizontal: 5).getPadding(),
          hintText: 'Alternate No',
          label: 'Alternate No',
          keyboardType: TextInputType.number,
          inputLength: 10,
          controller: alternateMobileNo,
          suffixIcon: Icon(CupertinoIcons.phone, size: 18),
        ),
        setHeight(height: 5),
        CommonTextField(
          obscureText: true,
          hintText: 'Password',
          label: 'Password',
          controller: password,
          marginPadding: SymmetricPadding(horizontal: 5).getPadding(),
          suffixIcon: Icon(CupertinoIcons.padlock, size: 18),
          validator: (passwordValue) {
            if (passwordValue!.isEmpty) {
              return emptyPassword;
            } else if (passwordValue.length < 6) {
              return shortPassword;
            } else {
              return null;
            }
          },
        ),
        setHeight(height: 5),
        CommonTextField(
          marginPadding: SymmetricPadding(horizontal: 5).getPadding(),
          obscureText: obscureText,
          hintText: 'Confirm Password',
          label: 'Confirm Password',
          controller: confirmpassword,
          suffixIcon: InkWell(
            onTap: onTap,
            child: Icon(
              obscureText ? CupertinoIcons.padlock : CupertinoIcons.lock_open,
              size: 18,
            ),
          ),
          validator: (passwordValue) {
            if (passwordValue!.isEmpty) {
              return emptyPassword;
            } else if (passwordValue.length < 6) {
              return shortPassword;
            } else if (password.text != confirmpassword.text) {
              return passwordMismatch;
            } else {
              return null;
            }
          },
        ),
      ],
    );
  }
}
