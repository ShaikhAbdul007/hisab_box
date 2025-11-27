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
  final bool astraIsRequred;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool isEveryThingAllowed;
  const CommonTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.contentPadding,
    this.keyboardType,
    this.inputLength,
    this.astraIsRequred = true,
    this.label,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.isEveryThingAllowed = false,
    this.obscureText = false,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 5),
          child: RichText(
            text: TextSpan(
              text: label ?? '',
              style: CustomTextStyle.customNato(letterSpacing: 1, fontSize: 14),
              children: [
                astraIsRequred
                    ? TextSpan(
                      text: ' *',
                      style: CustomTextStyle.customNato(
                        color: AppColors.redColor,
                      ),
                    )
                    : TextSpan(text: ''),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.greyColorShade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            textCapitalization: TextCapitalization.words,
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
              isEveryThingAllowed
                  ? FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9s]'))
                  : FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9@./&\s]'),
                  ),

              LengthLimitingTextInputFormatter(inputLength),
            ],
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon,
              contentPadding:
                  contentPadding ?? EdgeInsets.only(top: 10, left: 15),
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: CustomTextStyle.customNato(
                fontSize: 11,
                color: AppColors.greyColor,
              ),
              errorStyle: CustomTextStyle.customNato(
                fontSize: 10,
                color: AppColors.redColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
