import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/module/setting/controller/setting_controller.dart';
import 'package:inventory/routes/routes.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/size.dart';
import '../../../helper/textstyle.dart';
import '../widget/setting_icon_container.dart';
import '../widget/settingtem.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Setting',
      isleadingButtonRequired: false,
      body: ListView(
        children: [
          Obx(
            () => SettingItem(
              subtitleReq: true,
              label: controller.storeName.value,
              subtitle: controller.email.value,
              // trailing: Icon(CupertinoIcons.square_pencil),
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
          // SettingItem(
          //   label: 'Change Password',
          //   trailing: Icon(CupertinoIcons.forward),
          //   leading: SettingIconContainer(icon: CupertinoIcons.lock),
          // ),
          SettingItem(
            label: 'Discounts',
            trailing: Icon(CupertinoIcons.forward),
            leading: SettingIconContainer(icon: CupertinoIcons.percent),
            onTap: () {
              AppRoutes.navigateRoutes(routeName: AppRouteName.discount);
            },
          ),
          SettingItem(
            label: 'Category',
            trailing: Icon(CupertinoIcons.forward),
            leading: SettingIconContainer(icon: CupertinoIcons.circle_grid_3x3),
            onTap: () {
              AppRoutes.navigateRoutes(routeName: AppRouteName.category);
            },
          ),
          SettingItem(
            label: 'Animal Category',
            trailing: Icon(CupertinoIcons.forward),
            leading: SettingIconContainer(icon: CupertinoIcons.circle_grid_3x3),
            onTap: () {
              AppRoutes.navigateRoutes(routeName: AppRouteName.animalCategory);
            },
          ),
          // SettingItem(
          //   label: 'Loose Category',
          //   trailing: Icon(CupertinoIcons.forward),
          //   leading: SettingIconContainer(icon: CupertinoIcons.bag),
          //   onTap: () {
          //     AppRoutes.navigateRoutes(routeName: AppRouteName.looseCategory);
          //   },
          // ),
          SettingItem(
            label: 'App Settings',
            trailing: Icon(CupertinoIcons.forward),
            leading: SettingIconContainer(icon: CupertinoIcons.gear),
            onTap: () {
              AppRoutes.navigateRoutes(routeName: AppRouteName.appsetting);
            },
          ),
          SettingItem(
            onTap: () async {
              logoutDialog();
            },
            label: 'Log Out',
            leading: SettingIconContainer(icon: CupertinoIcons.power),
          ),
        ],
      ),
    );
  }

  void logoutDialog() {
    Get.defaultDialog(
      title: '',
      titleStyle: CustomTextStyle.customNato(fontSize: 0),
      titlePadding: EdgeInsets.zero,
      barrierDismissible: false,
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
          Divider(),
          Text(
            'Are you sure you want to log out ?',
            style: CustomTextStyle.customPoppin(fontSize: 15),
          ),
          setHeight(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(
                () => CommonButton(
                  width: 120,
                  isLoading: controller.isUserlogout.value,
                  label: "Yes",
                  onTap: () async {
                    await controller.userlogout();
                  },
                ),
              ),
              CommonButton(
                isbgReq: false,
                width: 120,
                isLoading: controller.isUserlogout.value,
                label: "No",
                onTap: () {
                  Get.back();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
