import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/credits_amount/view/credit_view.dart';
import 'package:inventory/module/customer/view/customer_view.dart';
import 'package:inventory/module/reports/view/report.dart';
import 'package:inventory/module/setting/view/setting.dart';
import 'package:inventory/responsive_layout/responsive_layout.dart';
import 'package:inventory/routes/routes.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:upgrader/upgrader.dart';
import '../../../routes/route_name.dart';
import '../../home/view/home.dart';
import '../controller/bottom_navigation_controller.dart';

class BottomNavigation extends GetView<BottomNavigationController> {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          titleTextStyle: CustomTextStyle.customPoppin(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.blackColor,
          ),
          contentTextStyle: CustomTextStyle.customPoppin(
            fontSize: 14,
            color: AppColors.blackColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.deepPurple,
            textStyle: CustomTextStyle.customPoppin(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      child: UpgradeAlert(
        dialogStyle: UpgradeDialogStyle.material,
        barrierDismissible: false,
        showIgnore: false,
        showLater: true,
        showReleaseNotes: true,
        upgrader: Upgrader(
          debugLogging: false,
          durationUntilAlertAgain: const Duration(hours: 12),
          messages: CustomUpgraderMessages(),
        ),
        child: ResponsiveLayout(
          desktop: DeskTopScreen(controller: controller),
          tablet: DeskTopScreen(controller: controller),
          mobile: MobileScreen(controller: controller),
        ),
      ),
    );
  }
}

class CustomUpgraderMessages extends UpgraderMessages {
  @override
  String message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.title:
        return 'New Update Available';
      case UpgraderMessage.body:
        return 'A better and more stable version is available. '
            'Please update now for latest fixes and improvements.';
      case UpgraderMessage.buttonTitleUpdate:
        return 'Update Now';
      case UpgraderMessage.buttonTitleLater:
        return 'Later';
      case UpgraderMessage.prompt:
        return 'Please update the app to continue with the best experience.';
      default:
        return super.message(messageKey) ?? 'Update available';
    }
  }
}

class DeskTopScreen extends StatelessWidget {
  final BottomNavigationController controller;
  const DeskTopScreen({super.key, required this.controller});

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
                size: 13.sp,
                color: AppColors.greyColor,
              ),
              title: Text(
                'Home',
                style: CustomTextStyle.customPoppin(
                  fontSize: controller.index.value == 0 ? 13 : 12,
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
                size: 20.sp,
              ),
            ),
            BottomBarItem(
              icon: Icon(CupertinoIcons.gear_alt, size: 13),
              title: Text(
                'Setting',
                style: CustomTextStyle.customPoppin(
                  fontSize: controller.index.value == 1 ? 13 : 12,
                  color:
                      controller.index.value == 0
                          ? AppColors.blackColor
                          : AppColors.greyColor,
                ),
              ),
              selectedIcon: Icon(
                CupertinoIcons.gear_alt_fill,
                color: AppColors.blackColor,
                size: 20.sp,
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

class MobileScreen extends StatelessWidget {
  final BottomNavigationController controller;
  const MobileScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.index.value,
          children: [
            HomeView(),
            CreditView(),
            ReportView(),
            CustomerView(),
            SettingView(),
          ],
        ),
      ),

      bottomNavigationBar: Obx(
        () => StylishBottomBar(
          borderRadius: BorderRadius.circular(8.r),
          currentIndex: controller.index.value,
          onTap: controller.setBottomIndex,
          backgroundColor: AppColors.whiteColor,
          elevation: 5,
          items: [
            BottomBarItem(
              icon: Icon(
                CupertinoIcons.house_alt,
                size: 13.sp,
                color: AppColors.greyColor,
              ),
              title: Text(
                'Home',
                style: CustomTextStyle.customPoppin(
                  fontSize: controller.index.value == 0 ? 13 : 12,
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
                size: 20.sp,
              ),
            ),
            BottomBarItem(
              icon: Icon(CupertinoIcons.money_dollar_circle, size: 13.sp),
              title: Text(
                'Credits',
                style: CustomTextStyle.customPoppin(
                  fontSize: controller.index.value == 1 ? 13 : 12,
                  color:
                      controller.index.value == 1
                          ? AppColors.blackColor
                          : AppColors.greyColor,
                ),
              ),
              selectedIcon: Icon(
                CupertinoIcons.money_dollar_circle_fill,
                color: AppColors.blackColor,
                size: 20.sp,
              ),
            ),
            BottomBarItem(
              icon: Icon(CupertinoIcons.chart_bar, size: 13),
              title: Text(
                'Reports',
                style: CustomTextStyle.customPoppin(
                  fontSize: controller.index.value == 2 ? 13 : 12,
                  color:
                      controller.index.value == 2
                          ? AppColors.blackColor
                          : AppColors.greyColor,
                ),
              ),
              selectedIcon: Icon(
                CupertinoIcons.chart_bar_fill,
                color: AppColors.blackColor,
                size: 20.sp,
              ),
            ),
            BottomBarItem(
              icon: Icon(
                CupertinoIcons.person,
                size: 13.sp,
                color: AppColors.greyColor,
              ),
              title: Text(
                'Customers',
                style: CustomTextStyle.customPoppin(
                  fontSize: controller.index.value == 3 ? 13 : 12,
                  color:
                      controller.index.value == 3
                          ? AppColors.blackColor
                          : AppColors.greyColor,
                ),
              ),
              unSelectedColor: AppColors.greyColor,
              selectedIcon: Icon(
                CupertinoIcons.person_fill,
                color: AppColors.blackColor,
                size: 20.sp,
              ),
            ),
            BottomBarItem(
              icon: Icon(CupertinoIcons.gear_alt, size: 13),
              title: Text(
                'Setting',
                style: CustomTextStyle.customPoppin(
                  fontSize: controller.index.value == 4 ? 13 : 12,
                  color:
                      controller.index.value == 4
                          ? AppColors.blackColor
                          : AppColors.greyColor,
                ),
              ),
              selectedIcon: Icon(
                CupertinoIcons.gear_alt_fill,
                color: AppColors.blackColor,
                size: 20.sp,
              ),
            ),
          ],
          //hasNotch: true,
          // notchStyle: NotchStyle.circle,
          // fabLocation: StylishBarFabLocation.center,
          option: AnimatedBarOptions(iconStyle: IconStyle.Default),
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     AppRoutes.navigateRoutes(
      //       routeName: AppRouteName.inventoryView,
      //       data: {'flag': false},
      //     );
      //   },
      //   backgroundColor: AppColors.whiteColor,
      //   shape: CircleBorder(),
      //   child: Icon(
      //     CupertinoIcons.barcode_viewfinder,
      //     color: AppColors.blackColor,
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
