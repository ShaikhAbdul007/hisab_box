import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

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
        setHeight(height: 10),
        CommonTextField(
          hintText: 'Mobile No',
          label: 'Mobile No',
          controller: mobileNo,
          inputLength: 10,
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
        setHeight(height: 10),
        CommonTextField(
          hintText: 'Alternate No',
          label: 'Alternate No',
          keyboardType: TextInputType.number,
          inputLength: 10,
          controller: alternateMobileNo,
          suffixIcon: Icon(CupertinoIcons.phone, size: 18),
        ),
        setHeight(height: 10),
        CommonTextField(
          obscureText: true,
          hintText: 'Password',
          label: 'Password',
          controller: password,
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
        setHeight(height: 10),
        CommonTextField(
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

class ShopAddress extends StatelessWidget {
  final TextEditingController shopName;
  final TextEditingController address;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController pincode;

  const ShopAddress({
    super.key,
    required this.shopName,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTextField(
          hintText: 'Shop Name',
          label: 'Shop Name',
          controller: shopName,
          suffixIcon: Icon(CupertinoIcons.person, size: 18),
          validator: (shopNameValue) {
            if (shopNameValue!.isEmpty) {
              return emptyShopName;
            } else {
              return null;
            }
          },
        ),
        setHeight(height: 10),
        CommonTextField(
          hintText: 'Address',
          label: 'Address',
          controller: address,
          suffixIcon: Icon(CupertinoIcons.location_solid, size: 18),
          validator: (address) {
            if (address!.isEmpty) {
              return emptyAddress;
            } else {
              return null;
            }
          },
        ),
        setHeight(height: 10),
        CommonTextField(
          hintText: 'City',
          label: 'City',
          controller: city,
          suffixIcon: Icon(CupertinoIcons.building_2_fill, size: 18),
          validator: (city) {
            if (city!.isEmpty) {
              return emptyCity;
            } else {
              return null;
            }
          },
        ),
        setHeight(height: 10),
        CommonTextField(
          hintText: 'State',
          label: 'State',
          controller: state,
          suffixIcon: Icon(Icons.business_outlined, size: 18),
          validator: (state) {
            if (state!.isEmpty) {
              return emptyState;
            } else {
              return null;
            }
          },
        ),
        setHeight(height: 10),
        CommonTextField(
          hintText: 'Pincode',
          label: 'Pincode',
          controller: pincode,
          suffixIcon: Icon(Icons.password, size: 18),
          validator: (pincode) {
            if (pincode!.isEmpty) {
              return emptyPincode;
            } else {
              return null;
            }
          },
        ),
      ],
    );
  }
}
