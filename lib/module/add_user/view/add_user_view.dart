import 'package:flutter/material.dart';
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
import 'package:inventory/keys/keys.dart';
import 'package:inventory/module/add_user/controller/add_user_controller.dart';
import 'package:inventory/module/add_user/widgets/permission_widgets.dart';

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
            PermissionWidgets(
              title: "Sales & Customers",
              keys: [
                'p_customer_list',
                'p_credit_list',
                'p_reconcile_credit',
                'p_see_today_sale',
                'p_see_today_sale_detail',
              ],
              permissions: controller.permissions,
            ),

            PermissionWidgets(
              title: "Revenue & Reports",
              keys: [
                'p_see_revenue',
                'p_see_received_cash',
                'p_see_received_credit',
                'p_see_received_card',
                'p_see_received_upi',
                'p_see_report',
              ],
              permissions: controller.permissions,
            ),

            PermissionWidgets(
              title: "Inventory Management",
              keys: [
                'p_add_product',
                'p_add_manual_product',
                'p_delete_product',
                'p_edit_product_details',
                'p_add_loose_product',
                'p_transfer_godown_to_shop',
              ],
              permissions: controller.permissions,
            ),
            PermissionWidgets(
              title: "Admin Settings",
              keys: ['p_add_user', 'p_add_bank_details', 'p_edit_profile'],
              permissions: controller.permissions,
            ),
            setHeight(height: 10),
            Obx(
              () => CustomPadding(
                paddingOption: SymmetricPadding(horizontal: 30),
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