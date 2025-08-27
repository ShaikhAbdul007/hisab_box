import 'package:flutter/material.dart';
import 'package:inventory/helper/textstyle.dart';

import 'colors.dart';

class CommonSearch extends StatelessWidget {
  final String label;
  final String hintText;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final TextEditingController controller;
  final bool isPaddingRequired;
  final Widget icon;

  const CommonSearch({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.onChanged,
    this.focusNode,
    this.isPaddingRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      style: CustomTextStyle.customPoppin(
        fontSize: 14,
        color: AppColors.blackColor,
      ),
      decoration: InputDecoration(
        suffixIcon: icon,
        isDense: true,
        contentPadding: EdgeInsets.all(10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.blackColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.blackColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.blackColor, width: 1),
        ),
        label: Text(
          label,
          style: CustomTextStyle.customUbuntu(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: AppColors.blackColor,
          ),
        ),
        hintText: hintText,
        hintStyle: CustomTextStyle.customUbuntu(
          fontWeight: FontWeight.w200,
          fontSize: 12,
          color: AppColors.blackColor,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
