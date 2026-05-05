import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/app_version.dart';
import 'package:inventory/module/setting/controller/setting_controller.dart';
import 'package:inventory/module/setting/widget/customer_support.dart';
import 'package:inventory/routes/routes.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_divider.dart';
import '../../../helper/textstyle.dart';
import '../../../routes/route_name.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Settings',
      isleadingButtonRequired: false,
      body: ListView(
        padding: SymmetricPadding(horizontal: 16, vertical: 12).getPadding(),
        children: [
          // ── Profile Card ─────────────────────────────────────────────
          _ProfileCard(controller: controller),
          setHeight(height: 20),

          // ── Account Section ──────────────────────────────────────────
          _SectionLabel(label: 'Account'),
          setHeight(height: 8),
          _SettingsGroup(
            items: [
              _SettingTile(
                icon: Icons.account_balance_rounded,
                iconColor: const Color(0xFF1565C0),
                label: 'Bank Details',
                subtitle: 'Manage your bank & UPI info',
                onTap:
                    () => AppRoutes.navigateRoutes(
                      routeName: AppRouteName.bankDetails,
                    ),
              ),
              _SettingTile(
                icon: CupertinoIcons.person_badge_plus_fill,
                iconColor: const Color(0xFF6A1B9A),
                label: 'Add User Role',
                subtitle: 'Create and manage staff roles',
                onTap:
                    () => AppRoutes.navigateRoutes(
                      routeName: AppRouteName.userRoleView,
                    ),
              ),
              _SettingTile(
                icon: CupertinoIcons.person_2_fill,
                iconColor: const Color(0xFF00695C),
                label: 'Add User',
                subtitle: 'Manage staff accounts',
                onTap:
                    () => AppRoutes.navigateRoutes(
                      routeName: AppRouteName.allUser,
                    ),
                isLast: true,
              ),
            ],
          ),
          setHeight(height: 20),

          // ── Inventory Section ─────────────────────────────────────────
          _SectionLabel(label: 'Inventory'),
          setHeight(height: 8),
          Obx(() {
            final supportsColor =
                controller.shopTypeEnum.config.supportsColorModule;
            return _SettingsGroup(
              items: [
                _SettingTile(
                  icon: CupertinoIcons.circle_grid_3x3_fill,
                  iconColor: const Color(0xFFE65100),
                  label: 'Category',
                  subtitle: 'Manage product categories',
                  onTap:
                      () => AppRoutes.navigateRoutes(
                        routeName: AppRouteName.category,
                      ),
                ),
                _SettingTile(
                  icon: CupertinoIcons.tag_fill,
                  iconColor: const Color(0xFF2E7D32),
                  label: controller.shopTypeEnum.config.categoryLabel,
                  subtitle:
                      'Manage ${controller.shopTypeEnum.config.categoryLabel.toLowerCase()}s',
                  onTap:
                      () => AppRoutes.navigateRoutes(
                        routeName: AppRouteName.animalCategory,
                        data: controller.shoptype.value,
                      ),
                  isLast: !supportsColor,
                ),
                if (supportsColor)
                  _SettingTile(
                    icon: CupertinoIcons.paintbrush_fill,
                    iconColor: const Color(0xFF6A1B9A),
                    label: 'Color Category',
                    subtitle: 'Manage color options',
                    onTap:
                        () => AppRoutes.navigateRoutes(
                          routeName: AppRouteName.colorCategory,
                        ),
                    isLast: true,
                  ),
              ],
            );
          }),
          setHeight(height: 20),

          // ── App Section ───────────────────────────────────────────────
          _SectionLabel(label: 'App'),
          setHeight(height: 8),
          _SettingsGroup(
            items: [
              _SettingTile(
                icon: CupertinoIcons.gear_alt_fill,
                iconColor: const Color(0xFF37474F),
                label: 'App Settings',
                subtitle: 'Scanner, godown & printer',
                onTap:
                    () => AppRoutes.navigateRoutes(
                      routeName: AppRouteName.appsetting,
                    ),
              ),
              _SettingTile(
                icon: Icons.support_agent_rounded,
                iconColor: const Color(0xFF0277BD),
                label: 'Support',
                subtitle: 'Get help from our team',
                onTap: () {
                  commonBottomSheet(
                    label: 'Customer Support',
                    onPressed: () => Get.back(),
                    child: CustomerSupport(
                      emailOnTap: () => controller.emailLauncher(),
                      phoneOnTap: () => controller.phoneluancher(),
                    ),
                  );
                },
                isLast: true,
              ),
            ],
          ),
          setHeight(height: 20),

          // ── Legal Section ─────────────────────────────────────────────
          _SectionLabel(label: 'Legal'),
          setHeight(height: 8),
          _SettingsGroup(
            items: [
              _SettingTile(
                icon: CupertinoIcons.lock_fill,
                iconColor: const Color(0xFF455A64),
                label: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap:
                    () => AppRoutes.navigateRoutes(
                      routeName: AppRouteName.privacypolicy,
                    ),
              ),
              _SettingTile(
                icon: CupertinoIcons.doc_text_fill,
                iconColor: const Color(0xFF455A64),
                label: 'Terms & Conditions',
                subtitle: 'Our terms of service',
                onTap:
                    () => AppRoutes.navigateRoutes(
                      routeName: AppRouteName.termandcodition,
                    ),
                isLast: true,
              ),
            ],
          ),
          setHeight(height: 20),

          // ── Logout ────────────────────────────────────────────────────
          _LogoutButton(onTap: () => _logoutDialog()),
          setHeight(height: 20),

          // ── App Version ───────────────────────────────────────────────
          _AppVersionCard(),
          setHeight(height: 30),
        ],
      ),
    );
  }

  void _logoutDialog() {
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: '',
      titleStyle: const TextStyle(fontSize: 0),
      titlePadding: EdgeInsets.zero,
      barrierDismissible: false,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Log Out',
                style: CustomTextStyle.customPoppin(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.clear, size: 20),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          CommonDivider(),
          setHeight(height: 12),
          Text(
            'Are you sure you want to log out?',
            style: CustomTextStyle.customPoppin(
              fontSize: 14,
              color: AppColors.greyColor,
            ),
            textAlign: TextAlign.center,
          ),
          setHeight(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.blackColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: CustomTextStyle.customPoppin(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              setWidth(width: 12),
              Expanded(
                child: Obx(
                  () => CommonButton(
                    bgColor: AppColors.redColor,
                    width: double.infinity,
                    isLoading: controller.isUserlogout.value,
                    label: 'Log Out',
                    onTap: () async => await controller.userlogout(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Profile Card ──────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final SettingController controller;
  const _ProfileCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final url = controller.profileImageUrl.value.trim();
      final file = controller.profileImage.value;

      Widget avatar;
      if (file != null && file.existsSync()) {
        avatar = CircleAvatar(radius: 32.r, backgroundImage: FileImage(file));
      } else if (url.isNotEmpty) {
        avatar = CircleAvatar(
          radius: 32.r,
          backgroundColor: AppColors.blackColor,
          child: ClipOval(
            child: Image.network(
              url,
              width: 64.w,
              height: 64.h,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Text(
                    'HB',
                    style: TextStyle(fontSize: 20.sp, color: Colors.white),
                  ),
            ),
          ),
        );
      } else {
        avatar = CircleAvatar(
          radius: 32.r,
          backgroundColor: AppColors.blackColor,
          child: Text(
            'HB',
            style: TextStyle(fontSize: 20.sp, color: Colors.white),
          ),
        );
      }

      return InkWell(
        onTap: () async {
          final res = await AppRoutes.futureNavigationToRoute(
            routeName: AppRouteName.userProfile,
          );
          if (res == true) controller.getUserName();
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              avatar,
              setWidth(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.storeName.value,
                      style: CustomTextStyle.customPoppin(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    setHeight(height: 3),
                    Text(
                      controller.email.value,
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 13,
                        color: AppColors.greyColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18.sp,
                color: AppColors.greyColor,
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: CustomTextStyle.customOpenSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.greyColor,
        ),
      ),
    );
  }
}

// ── Settings Group (card with dividers) ───────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<Widget> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: items),
    );
  }
}

// ── Single Setting Tile ───────────────────────────────────────────────────────
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLast;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius:
              isLast
                  ? BorderRadius.only(
                    bottomLeft: Radius.circular(14.r),
                    bottomRight: Radius.circular(14.r),
                  )
                  : BorderRadius.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 20.sp),
                ),
                setWidth(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: CustomTextStyle.customPoppin(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 12,
                          color: AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16.sp,
                  color: AppColors.greyColor,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}

// ── App Version Card ──────────────────────────────────────────────────────────
class _AppVersionCard extends StatelessWidget {
  const _AppVersionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: AppColors.blackColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: Image.asset(
                'assets/hisabboxlogo.png',
                color: AppColors.blackColor,
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) => Icon(
                      Icons.inventory_2_rounded,
                      color: AppColors.blackColor,
                      size: 18.sp,
                    ),
              ),
            ),
          ),
          setWidth(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HisaabBox',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Smart Billing & Inventory',
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.blackColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                AppVersion.display,
                style: CustomTextStyle.customNato(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logout Button ─────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                CupertinoIcons.power,
                color: Colors.red.shade600,
                size: 20.sp,
              ),
            ),
            setWidth(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Out',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade600,
                    ),
                  ),
                  Text(
                    'Sign out from your account',
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 12,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16.sp,
              color: Colors.red.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
