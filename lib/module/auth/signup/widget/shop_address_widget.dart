import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../common_widget/size.dart';
import '../../../../common_widget/textfiled.dart';
import '../../../../helper/app_message.dart';

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
