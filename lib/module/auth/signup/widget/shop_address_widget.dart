import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_dropdown.dart';
import 'package:inventory/common_widget/common_padding.dart';
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

  Widget commonSuffixIcon(IconData icon) {
    return CustomPadding(
      paddingOption: OnlyPadding(right: 10),
      child: Icon(icon, size: 18),
    );
  }

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
                      ? const Text(
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
                  icon: const Icon(Icons.edit, color: Colors.black),
                ),
              ),
            ),
          ],
        ),

        /// Shop Name
        CommonTextField(
          hintText: 'Shop Name',
          label: 'Shop Name',
          controller: shopName,
          suffixIcon: commonSuffixIcon(CupertinoIcons.person),
          validator: (value) {
            if (value!.isEmpty) return emptyShopName;
            return null;
          },
        ),

        setHeight(height: 10),

        /// Address
        CommonTextField(
          hintText: 'Address',
          label: 'Address',
          controller: address,
          suffixIcon: commonSuffixIcon(CupertinoIcons.location_solid),
          validator: (value) {
            if (value!.isEmpty) return emptyAddress;
            return null;
          },
        ),

        setHeight(height: 10),

        /// City
        CommonTextField(
          hintText: 'City',
          label: 'City',
          controller: city,
          suffixIcon: commonSuffixIcon(CupertinoIcons.building_2_fill),
          validator: (value) {
            if (value!.isEmpty) return emptyCity;
            return null;
          },
        ),

        setHeight(height: 10),

        /// State
        CommonTextField(
          hintText: 'State',
          label: 'State',
          controller: state,
          suffixIcon: commonSuffixIcon(Icons.business_outlined),
          validator: (value) {
            if (value!.isEmpty) return emptyState;
            return null;
          },
        ),

        setHeight(height: 10),

        /// Shop Type
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

        /// Pincode
        CommonTextField(
          hintText: 'Pincode',
          label: 'Pincode',
          inputLength: 6,
          keyboardType: TextInputType.number,
          controller: pincode,
          suffixIcon: commonSuffixIcon(Icons.password),
          validator: (value) {
            if (value!.isEmpty) return emptyPincode;
            return null;
          },
        ),
      ],
    );
  }
}
