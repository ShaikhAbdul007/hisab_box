import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/common_padding.dart';
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
  final EdgeInsetsGeometry? marginPadding;
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
    this.marginPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomPadding(
          paddingOption: OnlyPadding(left: 8.0, bottom: 5),
          child: RichText(
            text: TextSpan(
              text: label ?? '',
              style: CustomTextStyle.customNato(letterSpacing: 1, fontSize: 11),
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
          margin:
              marginPadding ?? SymmetricPadding(horizontal: 10).getPadding(),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor, width: 0.5.w),
            borderRadius: BorderRadius.circular(10.r),
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
            cursorHeight: 14.sp,
            cursorColor: AppColors.blackColor,
            style: CustomTextStyle.customOpenSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
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
                  contentPadding ?? OnlyPadding(top: 10, left: 15).getPadding(),
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: CustomTextStyle.customNato(
                fontSize: 11,
                color: AppColors.greyColor,
              ),
              // fillColor: AppColors.greyColorShade100,
              // filled: true,

              // errorBorder: OutlineInputBorder(
              //   borderSide: BorderSide(color: AppColors.greyColor),
              //   borderRadius: BorderRadius.circular(10.r),
              // ),
              // enabledBorder: OutlineInputBorder(
              //   borderSide: BorderSide(color: AppColors.greyColor),
              //   borderRadius: BorderRadius.circular(10.r),
              // ),
              // focusedBorder: OutlineInputBorder(
              //   borderSide: BorderSide(color: AppColors.greyColor,),
              //   borderRadius: BorderRadius.circular(10.r),
              // ),
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
