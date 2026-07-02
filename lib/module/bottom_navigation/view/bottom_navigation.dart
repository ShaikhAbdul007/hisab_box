import 'package:inventory/module/inventorylist/view/inventroy_list.dart';
import 'package:inventory/module/sell/view/sell.dart';
import 'package:inventory/module/sell/view/sell_list_after_scan.dart';
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
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:upgrader/upgrader.dart';
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
      body: Row(
        children: [
          // Left Sidebar Drawer
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: AppColors.blackColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    top: 40,
                    bottom: 30,
                    right: 24,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          CupertinoIcons.cube_box_fill,
                          color: AppColors.whiteColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HisaabBox',
                            style: CustomTextStyle.customPoppin(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.whiteColor,
                            ),
                          ),
                          Text(
                            'Web POS Suite',
                            style: CustomTextStyle.customOpenSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 20),

                // Menu Items
                Expanded(
                  child: Obx(() {
                    final selectedIndex = controller.desktopIndex.value;
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _SidebarMenuItem(
                          icon: CupertinoIcons.square_grid_2x2_fill,
                          label: 'Dashboard',
                          isSelected: selectedIndex == 0,
                          onTap: () => controller.setDesktopIndex(0),
                        ),
                        _SidebarMenuItem(
                          icon: Icons.paid,
                          label: 'POS Billing',
                          isSelected: selectedIndex == 1,
                          onTap: () => controller.setDesktopIndex(1),
                        ),
                        _SidebarMenuItem(
                          icon: CupertinoIcons.cube_fill,
                          label: 'Inventory',
                          isSelected: selectedIndex == 2,
                          onTap: () => controller.setDesktopIndex(2),
                        ),
                        _SidebarMenuItem(
                          icon: CupertinoIcons.money_dollar_circle_fill,
                          label: 'Credit Ledger',
                          isSelected: selectedIndex == 3,
                          onTap: () => controller.setDesktopIndex(3),
                        ),
                        _SidebarMenuItem(
                          icon: CupertinoIcons.person_2_fill,
                          label: 'Customers',
                          isSelected: selectedIndex == 4,
                          onTap: () => controller.setDesktopIndex(4),
                        ),
                        _SidebarMenuItem(
                          icon: CupertinoIcons.time_solid,
                          label: 'Sales History',
                          isSelected: selectedIndex == 5,
                          onTap: () => controller.setDesktopIndex(5),
                        ),
                        _SidebarMenuItem(
                          icon: CupertinoIcons.chart_bar_fill,
                          label: 'Reports',
                          isSelected: selectedIndex == 6,
                          onTap: () => controller.setDesktopIndex(6),
                        ),
                        _SidebarMenuItem(
                          icon: CupertinoIcons.gear_solid,
                          label: 'Settings',
                          isSelected: selectedIndex == 7,
                          onTap: () => controller.setDesktopIndex(7),
                        ),
                      ],
                    );
                  }),
                ),

                // Footer
                const Divider(color: Colors.white10, height: 1),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white24,
                        radius: 18,
                        child: Icon(
                          CupertinoIcons.person_fill,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Mode',
                              style: CustomTextStyle.customPoppin(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.whiteColor,
                              ),
                            ),
                            Text(
                              'HisaabBox POS',
                              style: CustomTextStyle.customOpenSans(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Panel Screen Content
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: Obx(
                () => IndexedStack(
                  index: controller.desktopIndex.value,
                  children: [
                    HomeView(),
                    SellListAfterScan(),
                    InventroyList(),
                    CreditView(),
                    CustomerView(),
                    SellView(),
                    ReportView(),
                    SettingView(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<_SidebarMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.deepPurple;
    final isSelected = widget.isSelected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        onHover: (hovered) {
          setState(() {
            _isHovered = hovered;
          });
        },
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? activeColor
                    : _isHovered
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color:
                    isSelected
                        ? AppColors.whiteColor
                        : _isHovered
                        ? AppColors.whiteColor
                        : Colors.grey.shade400,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                widget.label,
                style: CustomTextStyle.customPoppin(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected
                          ? AppColors.whiteColor
                          : _isHovered
                          ? AppColors.whiteColor
                          : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
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
                  fontSize: controller.index.value == 3 ? 12 : 12,
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
