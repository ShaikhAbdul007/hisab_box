import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_dropdown.dart';
import '../../../../common_widget/size.dart';
import '../../../../common_widget/textfiled.dart';
import '../../../../helper/app_message.dart';

class ShopAddress extends StatelessWidget {
  final TextEditingController shopName;
  final TextEditingController address;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController pincode;
  final File profileImage;
  final void Function()? onPressed;
  final Function(dynamic) notifyParent;
  const ShopAddress({
    super.key,
    required this.shopName,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.profileImage,
    this.onPressed,
    required this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black,
              backgroundImage:
                  profileImage.path.isNotEmpty ? FileImage(profileImage) : null,
              child:
                  profileImage.path.isEmpty
                      ? Text(
                        "H",
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      )
                      : null,
            ),
            Positioned(
              top: 65.h,
              left: 65.w,
              child: Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: onPressed,
                  icon: Icon(Icons.edit, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
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
        CommonDropDown(
          isModelValueEnabled: false,
          enabled: true,
          dropDownBgColor: AppColors.greyColorShade100,
          errorText: 'Select shop type',
          listItems: ['Pet Shop'],
          hintText: 'Shop type',
          notifyParent: notifyParent,
        ),
        setHeight(height: 10),
        CommonTextField(
          hintText: 'Pincode',
          label: 'Pincode',
          inputLength: 6,
          keyboardType: TextInputType.number,
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
