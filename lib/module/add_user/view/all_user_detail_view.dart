import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/add_user/controller/all_user_detail_controller.dart';
import 'package:inventory/module/add_user/widgets/permission_widgets.dart';

class AllUserDetailView extends GetView<AllUserDetailController> {
  const AllUserDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'User Details',
      firstActionChild: InkWell(
        onTap: () {
          controller.isEditingEnable.value = !controller.isEditingEnable.value;
        },
        child: Obx(
          () => Icon(
            CupertinoIcons.square_pencil_fill,
            color:
                controller.isEditingEnable.value
                    ? AppColors.redColor
                    : AppColors.blackColor,
          ),
        ),
      ),
      body: ListView(
        children: [
          CommonTextField(
            readOnly: true,
            label: 'Staff Name',
            hintText: 'Staff Name',
            controller: controller.nameController,
          ),
          CommonTextField(
            readOnly: true,
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
            readOnly: true,
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
          setHeight(height: 10),

          CommonTextField(
            readOnly: true,
            label: 'Role',
            hintText: 'Role',
            controller: controller.roleController,
            keyboardType: TextInputType.phone,
            inputLength: 10,
            validator: (value) {
              if (value!.isEmpty) return emptyMobileNo;
              if (value.length < 10) return shortPassword;
              return null;
            },
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
              child:
                  controller.isEditingEnable.value
                      ? CommonButton(
                        isLoading: controller.isUpdateEmployeeLoading.value,
                        label: 'Save',
                        onTap: () async {
                          Map<String, dynamic> body = {"permissions": {}};
                          controller.permissions.forEach((key, value) {
                            body["permissions"][key] = value.value;
                          });
                          String employeeId = controller.data.id ?? '';
                          AppLogger.info(body.toString());
                          await controller.updateEmployeePermission(
                            body: body,
                            employeeId: employeeId,
                          );
                        },
                      )
                      : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
