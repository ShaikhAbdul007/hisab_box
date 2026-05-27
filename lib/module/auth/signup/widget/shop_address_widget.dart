import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/common_dropdown.dart';
import 'package:inventory/common_widget/common_padding.dart';
import '../../../../common_widget/colors.dart';
import '../../../../common_widget/textfiled.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/textstyle.dart';

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
      child: Icon(icon, size: 18.sp, color: Colors.grey.shade500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),

        // ── Profile avatar ─────────────────────────────────────────────
        _buildAvatarSection(),

        SizedBox(height: 24.h),

        // ── Shop info section ──────────────────────────────────────────
        _sectionLabel('Shop Information'),
        SizedBox(height: 12.h),

        _modernField(
          child: CommonTextField(
            hintText: 'Enter your shop name',
            label: 'Shop Name',
            controller: shopName,
            marginPadding: EdgeInsets.zero,
            suffixIcon: commonSuffixIcon(CupertinoIcons.bag),
            validator: (value) {
              if (value!.isEmpty) return emptyShopName;
              return null;
            },
          ),
        ),

        SizedBox(height: 14.h),

        // Shop Type dropdown
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: CustomStaticDropDown(
              listItems: ['Pet Shop', 'Clothing Shop'],
              hintText: 'Shop type',
              notifyParent: notifyParent,
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // ── Address section ────────────────────────────────────────────
        _sectionLabel('Shop Address'),
        SizedBox(height: 12.h),

        _modernField(
          child: CommonTextField(
            hintText: 'Street address, building, area',
            label: 'Address',
            controller: address,
            marginPadding: EdgeInsets.zero,
            suffixIcon: commonSuffixIcon(CupertinoIcons.location_solid),
            validator: (value) {
              if (value!.isEmpty) return emptyAddress;
              return null;
            },
          ),
        ),

        SizedBox(height: 14.h),

        // City & State in a row
        Row(
          children: [
            Expanded(
              child: _modernField(
                child: CommonTextField(
                  hintText: 'City',
                  label: 'City',
                  controller: city,
                  marginPadding: EdgeInsets.zero,
                  suffixIcon: commonSuffixIcon(CupertinoIcons.building_2_fill),
                  validator: (value) {
                    if (value!.isEmpty) return emptyCity;
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _modernField(
                child: CommonTextField(
                  hintText: 'State',
                  label: 'State',
                  controller: state,
                  marginPadding: EdgeInsets.zero,
                  suffixIcon: commonSuffixIcon(Icons.business_outlined),
                  validator: (value) {
                    if (value!.isEmpty) return emptyState;
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 14.h),

        _modernField(
          child: CommonTextField(
            hintText: '6-digit pincode',
            label: 'Pincode',
            inputLength: 6,
            keyboardType: TextInputType.number,
            controller: pincode,
            marginPadding: EdgeInsets.zero,
            suffixIcon: commonSuffixIcon(Icons.pin_drop_outlined),
            validator: (value) {
              if (value!.isEmpty) return emptyPincode;
              return null;
            },
          ),
        ),

        SizedBox(height: 20.h),
      ],
    );
  }

  // ── Avatar section ─────────────────────────────────────────────────────────
  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar ring
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 52.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  profileImage.path.isNotEmpty ? FileImage(profileImage) : null,
              child:
                  profileImage.path.isEmpty
                      ? Text(
                        'H',
                        style: TextStyle(
                          fontSize: 38.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                        ),
                      )
                      : null,
            ),
          ),

          // Edit button
          Positioned(
            bottom: 0,
            right: -4.w,
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                width: 34.w,
                height: 34.h,
                decoration: BoxDecoration(
                  color: AppColors.blackColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: AppColors.blackColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: CustomTextStyle.customPoppin(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
      ],
    );
  }

  Widget _modernField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(14.r), child: child),
    );
  }
}
