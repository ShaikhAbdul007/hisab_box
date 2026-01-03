import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/keys/keys.dart';
import 'package:inventory/module/bank_details/controller/bankdetails_controller.dart';

class BankdetailsView extends GetView<BankdetailsController> {
  const BankdetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Bank Details',
      body: CustomPadding(
        paddingOption: SymmetricPadding(horizontal: 12.0),
        child: Form(
          key: formkeys,
          child: Obx(
            () =>
                controller.setBankDetailsUpi.value
                    ? CommonProgressbar(color: AppColors.blackColor)
                    : ListView(
                      children: [
                        CommonTextField(
                          hintText: 'Bank Name',
                          label: 'Bank name',
                          controller: controller.bankNameController,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Bank name is required";
                            }
                            if (v.trim().length < 3) {
                              return "Bank name must be at least 3 letters";
                            }
                            return null;
                          },
                        ),

                        setHeight(height: 5),

                        CommonTextField(
                          hintText: 'Account Holder Name',
                          label: 'Account Holder Name',
                          controller: controller.accountHolderNameController,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "Account holder name is required";
                            }
                            if (!RegExp(
                              r"^[a-zA-Z\s.]{3,}$",
                            ).hasMatch(v.trim())) {
                              return "Enter a valid name";
                            }
                            return null;
                          },
                        ),

                        setHeight(height: 5),

                        CommonTextField(
                          hintText: 'UPI ID',
                          label: 'UPI ID',
                          controller: controller.upiIdController,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "UPI ID is required";
                            }
                            if (!controller.isValidUpi(v.trim())) {
                              return "Enter valid UPI ID (example: name@bank)";
                            }
                            return null;
                          },
                        ),

                        setHeight(height: 30),
                        Obx(
                          () => CustomPadding(
                            paddingOption: SymmetricPadding(horizontal: 30),
                            child: CommonButton(
                              isLoading: controller.bankDetailsUpi.value,
                              label: 'Save',
                              onTap: () {
                                if (formkeys.currentState!.validate()) {
                                  unfocus();
                                  controller.saveBankDetails();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
