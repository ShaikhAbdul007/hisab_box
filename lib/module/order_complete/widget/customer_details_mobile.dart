import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/order_complete/controller/order_controller.dart';

import '../../../common_widget/colors.dart';
import '../../../helper/textstyle.dart';
import '../model/customer_details_model.dart';

class CustomerDetailsMobileAutoCompleteWidget extends StatelessWidget {
  final OrderController controller;
  const CustomerDetailsMobileAutoCompleteWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<CustomerDetails>(
      optionsBuilder: (TextEditingValue tController) {
        if (tController.text.isEmpty) {
          controller.clear();
          return const Iterable<CustomerDetails>.empty();
        }
        return controller.customerDetails.where((e) {
          final name = e.name!.toLowerCase();
          final mobile = e.mobile!;
          final address = e.address!.toLowerCase();
          final query = tController.text.toLowerCase();

          return name.contains(query) ||
              mobile.contains(query) ||
              address.contains(query);
        });
      },
      displayStringForOption: (option) => option.mobile ?? "",
      onSelected: (option) {
        controller.setDataAsPerOptionSelecte(option);
      },
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomPadding(
              paddingOption: OnlyPadding(left: 8.0),
              child: RichText(
                text: TextSpan(
                  text: 'Mobile Number',
                  style: CustomTextStyle.customNato(
                    letterSpacing: 1,
                    fontSize: 11,
                  ),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: CustomTextStyle.customNato(
                        color: AppColors.redColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            setHeight(height: 5),
            Container(
              margin: SymmetricPadding(horizontal: 10).getPadding(),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.greyColor, width: 0.5.w),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                autocorrect: true,
                cursorHeight: 14.sp,
                cursorColor: AppColors.blackColor,
                style: CustomTextStyle.customOpenSans(fontSize: 15),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9s]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                keyboardType: TextInputType.number,
                validator: (no) {
                  if (no?.isEmpty ?? false) {
                    return 'Enter mobile no';
                  } else if (no!.length > 10) {
                    return 'Mobile no should be 10 digit';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  contentPadding: OnlyPadding(top: 10, left: 15).getPadding(),
                  border: InputBorder.none,
                  hintText: 'Mobile No',
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
                  //   borderSide: BorderSide(color: AppColors.greyColor),
                  //   borderRadius: BorderRadius.circular(10.r),
                  // ),
                  errorStyle: CustomTextStyle.customNato(
                    fontSize: 10,
                    color: AppColors.redColor,
                  ),
                ),
                onChanged: (val) {
                  controller.mobileNumber.text = val;
                  customMessageOrErrorPrint(
                    message: controller.mobileNumber.text,
                  );
                },
              ),
            ),
          ],
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return CustomPadding(
          paddingOption: SymmetricPadding(horizontal: 16.0),
          child: Material(
            color: AppColors.greyColorShade100,
            elevation: 5,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.r),
              bottomRight: Radius.circular(10.r),
            ),
            child: SizedBox(
              height: 150.h,
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final customer = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(customer),
                    child: CustomerDetailsMobileAutoCompleteOptionContainer(
                      mobile: customer.mobile ?? "",
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomerDetailsMobileAutoCompleteOptionContainer extends StatelessWidget {
  final String mobile;
  const CustomerDetailsMobileAutoCompleteOptionContainer({
    super.key,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 700.w,
      height: 40.h,
      margin: OnlyPadding(left: 5, bottom: 5, right: 5, top: 8).getPadding(),
      padding: OnlyPadding(top: 5, left: 8.0, bottom: 5).getPadding(),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(mobile, style: CustomTextStyle.customMontserrat()),
    );
  }
}
