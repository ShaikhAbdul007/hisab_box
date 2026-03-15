import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_dropdown.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/keys/keys.dart';
import 'package:inventory/module/add_user/controller/add_user_controller.dart';

class AddUserView extends GetView<AddUserController> {
  const AddUserView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Add User',
      body: Form(
        key: inventoryScanKey,
        child: ListView(
          children: [
            CommonTextField(
              label: 'Staff Name',
              hintText: 'Staff Name',
              controller: controller.nameController,
            ),
            CommonTextField(
              textCapitalization: TextCapitalization.none,
              label: 'Email',
              hintText: 'Email',
              controller: controller.emailController,
              validator: (emailValue) {
                if (emailValue!.isEmpty) return emptyEmail;
                if (!GetUtils.isEmail(emailValue)) return invalidEmail;
                return null;
              },
            ),
            CommonTextField(
              label: 'Password',
              hintText: 'Password',
              controller: controller.passwordController,
              validator: (value) {
                if (value!.isEmpty) return emptyPassword;
                if (value.length < 6) return shortPassword;
                return null;
              },
            ),
            CommonTextField(
              label: 'Mobile No',
              hintText: 'Mobile No',
              controller: controller.mobileController,
              keyboardType: TextInputType.phone,
              inputLength: 10,
              validator: (value) {
                if (value!.isEmpty) return emptyMobileNo;
                if (value.length < 10) return shortPassword;
                return null;
              },
            ),
            CommonDropDown(
              isModelValueEnabled: false,
              listItems: ['Staff', 'Manager'],
              hintText: 'Select Role',
              notifyParent: (v) {
                controller.selectedRole.value = v;
                unfocus();
              },
              errorText: 'Select staff type',
            ),
            setHeight(height: 10),
            buildPermissionSection("Sales & Customers", [
              'p_customer_list',
              'p_credit_list',
              'p_reconcile_credit',
              'p_see_today_sale',
              'p_see_today_sale_detail',
            ]), // Index 0
            setHeight(height: 10),
            buildPermissionSection("Revenue & Reports", [
              'p_see_revenue',
              'p_see_received_cash',
              'p_see_received_credit',
              'p_see_received_card',
              'p_see_received_upi',
              'p_see_report',
            ]), // Index 1
            setHeight(height: 10),
            buildPermissionSection("Inventory Management", [
              'p_add_product',
              'p_add_manual_product',
              'p_delete_product',
              'p_edit_product_details',
              'p_add_loose_product',
              'p_transfer_godown_to_shop',
            ]), // Index 2
            setHeight(height: 10),
            buildPermissionSection("Admin Settings", [
              'p_add_user',
              'p_add_bank_details',
              'p_edit_profile',
            ]),
            setHeight(height: 10),
            Obx(
              () => CustomPadding(
                paddingOption: SymmetricPadding(horizontal: 10),
                child: CommonButton(
                  isLoading: controller.isLoading.value,
                  label: 'Save',
                  onTap: () {
                    if (inventoryScanKey.currentState!.validate()) {
                      //  controller.createStaffAccount();
                      Map<String, dynamic> finalData = {
                        'name': controller.nameController.text.trim(),
                        'mobile_no': controller.mobileController.text.trim(),
                        'role': controller.selectedRole.value,
                        // 'parent_id': effectiveShopId,
                      };

                      // Permissions add karna
                      controller.permissions.forEach((key, value) {
                        finalData[key] = value.value;
                      });

                      // Aapka sawal: Object print karna
                      debugPrint("Final Object to Save: $finalData");
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPermissionSection(String title, List<String> keys) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.greyColor),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.greyColor),
        ),
        title: Text(
          title,
          style: CustomTextStyle.customOpenSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),

        children:
            keys.map((key) {
              return Obx(
                () => SwitchListTile(
                  activeThumbColor: AppColors.blackColor,
                  activeTrackColor: AppColors.greyColor,
                  inactiveThumbColor: AppColors.greyColor,
                  inactiveTrackColor: AppColors.blackColor,
                  title: Text(
                    key
                        .replaceAll('p_', '')
                        .replaceAll('_', ' ')
                        .capitalizeFirst!,
                    style: CustomTextStyle.customMontserrat(),
                  ),
                  value: controller.permissions[key]!.value,
                  onChanged: (val) => controller.permissions[key]!.value = val,
                ),
              );
            }).toList(),
      ),
    );
  }
}
   // Role Selection
          // DropdownButton<String>(
          //   value: controller.selectedRole.value,
          //   items:
          //       ['staff', 'manager']
          //           .map(
          //             (role) =>
          //                 DropdownMenuItem(value: role, child: Text(role)),
          //           )
          //           .toList(),
          //   onChanged: (val) => controller.selectedRole.value = val!,
          // ),