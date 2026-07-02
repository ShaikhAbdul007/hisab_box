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

  double _w(double width) => ScreenUtil().screenWidth > 600 ? width : width.w;
  double _h(double height) => ScreenUtil().screenWidth > 600 ? height : height.h;
  double _r(double radius) => ScreenUtil().screenWidth > 600 ? radius : radius.r;
  double _sp(double sp) => ScreenUtil().screenWidth > 600 ? sp : sp.sp;

  Widget commonSuffixIcon(IconData icon) {
    return CustomPadding(
      paddingOption: OnlyPadding(right: 10),
      child: Icon(icon, size: _sp(18), color: Colors.grey.shade500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: _h(8)),

        // ── Profile avatar ─────────────────────────────────────────────
        _buildAvatarSection(),

        SizedBox(height: _h(24)),

        // ── Shop info section ──────────────────────────────────────────
        _sectionLabel('Shop Information'),
        SizedBox(height: _h(12)),

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

        SizedBox(height: _h(14)),

        // Shop Type dropdown
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_r(14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_r(14)),
            child: CustomStaticDropDown(
              listItems: const ['Pet Shop', 'Clothing Shop'],
              hintText: 'Shop type',
              notifyParent: notifyParent,
            ),
          ),
        ),

        SizedBox(height: _h(24)),

        // ── Address section ────────────────────────────────────────────
        _sectionLabel('Shop Address'),
        SizedBox(height: _h(12)),

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

        SizedBox(height: _h(14)),

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
            SizedBox(width: _w(12)),
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

        SizedBox(height: _h(14)),

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

        SizedBox(height: _h(20)),
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
            padding: EdgeInsets.all(_w(3)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: _r(52),
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  profileImage.path.isNotEmpty ? FileImage(profileImage) : null,
              child: profileImage.path.isEmpty
                  ? Text(
                      'H',
                      style: TextStyle(
                        fontSize: _sp(38),
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
            right: -_w(4),
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                width: _w(34),
                height: _h(34),
                decoration: BoxDecoration(
                  color: AppColors.blackColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: _sp(16),
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
          width: _w(3),
          height: _h(16),
          decoration: BoxDecoration(
            color: AppColors.blackColor,
            borderRadius: BorderRadius.circular(_r(2)),
          ),
        ),
        SizedBox(width: _w(8)),
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
        borderRadius: BorderRadius.circular(_r(14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(_r(14)), child: child),
    );
  }
}
