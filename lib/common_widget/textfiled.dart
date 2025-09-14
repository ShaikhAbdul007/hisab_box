import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helper/textstyle.dart';
import 'colors.dart';

class CommonTextField extends StatelessWidget {
  final String hintText;
  final String? label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int? inputLength;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final bool obscureText;
  final bool readOnly;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  const CommonTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.contentPadding,
    this.keyboardType,
    this.inputLength,
    this.label,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.greyColorShade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        onChanged: onChanged,
        readOnly: readOnly,
        obscureText: obscureText,
        obscuringCharacter: '*',
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator,
        keyboardType: keyboardType,
        controller: controller,
        autocorrect: true,
        cursorHeight: 15,
        cursorColor: AppColors.blackColor,
        style: CustomTextStyle.customUbuntu(fontSize: 15),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@./&\s]')),
          LengthLimitingTextInputFormatter(inputLength),
        ],
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          contentPadding: contentPadding ?? EdgeInsets.only(top: 10, left: 15),
          border: InputBorder.none,
          hintText: hintText,
          label: Text(
            label ?? '',
            style: CustomTextStyle.customNato(
              fontSize: 12,
              color: AppColors.blackColor,
            ),
          ),
          hintStyle: CustomTextStyle.customNato(
            fontSize: 12,
            color: AppColors.greyColor,
          ),
          errorStyle: CustomTextStyle.customNato(
            fontSize: 10,
            color: AppColors.redColor,
          ),
        ),
      ),
    );
  }
}
