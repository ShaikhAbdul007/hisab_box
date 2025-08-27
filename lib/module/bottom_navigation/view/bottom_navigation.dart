import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/setting/view/setting.dart';
import 'package:inventory/routes/routes.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import '../../home/view/home.dart';
import '../controller/bottom_navigation_controller.dart';

class BottomNavigation extends GetView<BottomNavigationController> {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.index.value,
          children: [HomeView(), SettingView()],
        ),
      ),
      bottomNavigationBar: Obx(
        () => StylishBottomBar(
          currentIndex: controller.index.value,
          onTap: controller.setBottomIndex,
          backgroundColor: AppColors.whiteColor,
          elevation: 5,
          items: [
            BottomBarItem(
              icon: Icon(
                CupertinoIcons.house_alt,
                size: 15,
                color: AppColors.greyColor,
              ),
              title: Text(
                'Home',
                style: CustomTextStyle.customPoppin(
                  fontSize: controller.index.value == 0 ? 15 : 12,
                  color:
                      controller.index.value == 0
                          ? AppColors.blackColor
                          : AppColors.greyColor,
                ),
              ),
              unSelectedColor: AppColors.greyColor,
              selectedIcon: Icon(
                CupertinoIcons.house_alt_fill,
                color: AppColors.blackColor,
                size: 20,
              ),
            ),
            BottomBarItem(
              icon: Icon(CupertinoIcons.gear_alt, size: 15),
              title: Text(
                'Setting',
                style: CustomTextStyle.customPoppin(
                  fontSize: controller.index.value == 1 ? 15 : 12,
                  color:
                      controller.index.value == 0
                          ? AppColors.blackColor
                          : AppColors.greyColor,
                ),
              ),
              selectedIcon: Icon(
                CupertinoIcons.gear_alt_fill,
                color: AppColors.blackColor,
                size: 20,
              ),
            ),
          ],
          hasNotch: true,
          notchStyle: NotchStyle.circle,
          fabLocation: StylishBarFabLocation.center,
          option: AnimatedBarOptions(iconStyle: IconStyle.Default),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRoutes.navigateRoutes(
            routeName: AppRouteName.inventoryView,
            data: {'flag': false},
          );
        },
        backgroundColor: AppColors.whiteColor,
        shape: CircleBorder(),
        child: Icon(
          CupertinoIcons.barcode_viewfinder,
          color: AppColors.blackColor,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
