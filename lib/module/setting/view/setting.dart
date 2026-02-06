import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_container.dart';
import 'package:inventory/module/setting/controller/setting_controller.dart';
import 'package:inventory/module/setting/widget/customer_support.dart';
import 'package:inventory/routes/routes.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_divider.dart';
import '../../../common_widget/common_padding.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/route_name.dart';
import '../widget/setting_icon_container.dart';
import '../widget/settingtem.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Settings',
      isleadingButtonRequired: false,
      body: CustomPadding(
        paddingOption: SymmetricPadding(horizontal: 15),
        child: ListView(
          children: [
            Obx(
              () => CommonContainer(
                height: 80,
                child: SettingItem(
                  onTap: () {
                    AppRoutes.navigateRoutes(
                      routeName: AppRouteName.userProfile,
                    );
                  },
                  subtitleReq: true,
                  label: controller.storeName.value,
                  subtitle: controller.email.value,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.blackColor,
                    radius: 25,
                    child: Text(
                      controller.storeName.value.isNotEmpty
                          ? controller.storeName.value.substring(0, 1)
                          : 'H',
                      style: CustomTextStyle.customRaleway(
                        fontSize: 25,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            setHeight(height: 5),
            CommonContainer(
              height: 85,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SettingItem(
                    label: 'Bank Details',
                    subtitle: 'Manage your bank details',
                    leading: SettingIconContainer(icon: Icons.account_balance),
                    onTap: () {
                      AppRoutes.navigateRoutes(
                        routeName: AppRouteName.bankDetails,
                      );
                    },
                  ),
                  // CommonDivider(indent: 20, endIndent: 20),
                  // SettingItem(
                  //   label:
                  //       controller.shoptype.value == 'petShop'
                  //           ? 'Animal Category'
                  //           : 'Size Category',
                  //   subtitle:
                  //       controller.shoptype.value == 'petShop'
                  //           ? 'Manage your animal categories'
                  //           : 'Manage your size categories',
                  //   leading: SettingIconContainer(
                  //     icon: CupertinoIcons.circle_grid_3x3,
                  //   ),
                  //   onTap: () {
                  //     AppRoutes.navigateRoutes(
                  //       routeName: AppRouteName.animalCategory,
                  //       data: controller.shoptype.value,
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
            setHeight(height: 5),
            CommonContainer(
              height: 170,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SettingItem(
                    label: 'Category',
                    subtitle: 'Manage your product categories',
                    leading: SettingIconContainer(
                      icon: CupertinoIcons.circle_grid_3x3,
                    ),
                    onTap: () {
                      AppRoutes.navigateRoutes(
                        routeName: AppRouteName.category,
                      );
                    },
                  ),
                  CommonDivider(indent: 20, endIndent: 20),
                  SettingItem(
                    label: 'Animal Category',
                    subtitle: 'Manage your animal categories',
                    leading: SettingIconContainer(
                      icon: CupertinoIcons.circle_grid_3x3,
                    ),
                    onTap: () {
                      AppRoutes.navigateRoutes(
                        routeName: AppRouteName.animalCategory,
                        data: controller.shoptype.value,
                      );
                    },
                  ),
                ],
              ),
            ),
            setHeight(height: 5),
            CommonContainer(
              height: 170,

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SettingItem(
                    label: 'App Settings',
                    subtitle: 'Manage your app settings',
                    leading: SettingIconContainer(icon: CupertinoIcons.gear),
                    onTap: () {
                      AppRoutes.navigateRoutes(
                        routeName: AppRouteName.appsetting,
                      );
                    },
                  ),
                  CommonDivider(indent: 20, endIndent: 20),
                  SettingItem(
                    label: 'Support',
                    subtitle: 'Get help & support',
                    leading: SettingIconContainer(icon: Icons.support_agent),
                    onTap: () {
                      commonBottomSheet(
                        label: ' Customer Support',
                        onPressed: () {
                          Get.back();
                        },
                        child: CustomerSupport(
                          emailOnTap: () => controller.emailLauncher(),
                          phoneOnTap: () => controller.phoneluancher(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            setHeight(height: 5),
            CommonContainer(
              height: 170,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SettingItem(
                    label: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    leading: SettingIconContainer(icon: CupertinoIcons.lock),
                    onTap: () {
                      AppRoutes.navigateRoutes(
                        routeName: AppRouteName.privacypolicy,
                      );
                    },
                  ),
                  CommonDivider(indent: 20, endIndent: 20),
                  SettingItem(
                    label: 'Terms & Conditions',
                    subtitle: 'Read our terms',
                    leading: SettingIconContainer(icon: CupertinoIcons.hexagon),
                    onTap: () {
                      AppRoutes.navigateRoutes(
                        routeName: AppRouteName.termandcodition,
                      );
                    },
                  ),
                ],
              ),
            ),
            setHeight(height: 5),
            CommonContainer(
              height: 80,
              child: SettingItem(
                onTap: () async {
                  logoutDialog();
                },
                label: 'Log Out',
                subtitle: 'Sign out from your account',
                leading: SettingIconContainer(icon: CupertinoIcons.power),
              ),
            ),
            setHeight(height: 5),
          ],
        ),
      ),
    );
  }

  void logoutDialog() {
    Get.defaultDialog(
      backgroundColor: AppColors.greyColorShade100,
      title: '',
      titleStyle: CustomTextStyle.customNato(fontSize: 0),
      titlePadding: EdgeInsets.zero,
      barrierDismissible: false,
      content: Column(
        children: [
          CustomPadding(
            paddingOption: SymmetricPadding(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Alert', style: CustomTextStyle.customNato(fontSize: 15)),
                IconButton(
                  icon: Icon(CupertinoIcons.clear),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
          ),
          setHeight(height: 5),
          CommonDivider(indent: 10, endIndent: 10),
          setHeight(height: 5),
          Text(
            'Are you sure you want to log out?',
            style: CustomTextStyle.customPoppin(),
          ),
          setHeight(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CommonButton(
                width: 120,
                isLoading: controller.isUserlogout.value,
                label: "No",
                onTap: () {
                  Get.back();
                },
              ),
              Obx(
                () => CommonButton(
                  bgColor: AppColors.buttonRedColor,
                  width: 120,
                  isLoading: controller.isUserlogout.value,
                  label: "Yes",
                  onTap: () async {
                    await controller.userlogout();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}





// SettingItem(
          //   label: 'Change Password',
          //   trailing: Icon(CupertinoIcons.forward),
          //   leading: SettingIconContainer(icon: CupertinoIcons.lock),
          // ),

           // Obx(
          //   () =>
          //       controller.discountPerProduct.value
          //           ? SettingItem(
          //             label: 'Discounts',
          //             trailing: Icon(CupertinoIcons.forward),
          //             leading: SettingIconContainer(
          //               icon: CupertinoIcons.percent,
          //             ),
          //             onTap: () {
          //               AppRoutes.navigateRoutes(
          //                 routeName: AppRouteName.discount,
          //               );
          //             },
          //           )
          //           : Container(),
          // ),