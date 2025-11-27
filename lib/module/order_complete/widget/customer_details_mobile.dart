import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: RichText(
                text: TextSpan(
                  text: 'Mobile Number',
                  style: CustomTextStyle.customNato(
                    letterSpacing: 1,
                    fontSize: 14,
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
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.greyColorShade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                autocorrect: true,
                cursorHeight: 15,
                cursorColor: AppColors.blackColor,
                style: CustomTextStyle.customUbuntu(fontSize: 15),

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
                  contentPadding: EdgeInsets.only(top: 10, left: 15),
                  border: InputBorder.none,
                  hintText: 'Mobile No',
                  hintStyle: CustomTextStyle.customNato(
                    fontSize: 13,
                    color: AppColors.greyColor,
                  ),
                  errorStyle: CustomTextStyle.customNato(
                    fontSize: 10,
                    color: AppColors.redColor,
                  ),
                ),
                onChanged: (val) {
                  controller.mobileNumber.text = val;
                  print(controller.mobileNumber.text);
                },
              ),
            ),
          ],
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Material(
            color: AppColors.greyColorShade100,
            elevation: 5,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: SizedBox(
              height: 150,
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
      width: 700,
      height: 40,
      margin: const EdgeInsets.only(left: 5, bottom: 5, right: 5),
      padding: const EdgeInsets.only(top: 5, left: 8.0, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(mobile, style: CustomTextStyle.customMontserrat()),
    );
  }
}
