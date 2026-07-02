import 'package:inventory/responsive_layout/dimension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/app_version.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/auth/splash/controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure navigation is triggered — safe to call multiple times
    // because Future.delayed only fires once.
    controller.movetoNextScreen();

    final desktop = isDesktop(context);
    final logoSize = desktop ? 120.0 : 120.w;
    final iconSize = desktop ? 80.0 : 80.sp;
    final loaderSize = desktop ? 22.0 : 22.w;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Main content — fully centered ────────────────────────────
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/hisabboxlogo.png',
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, _, _) =>
                            Icon(Icons.inventory_2_rounded, size: iconSize),
                  ),

                  const SizedBox(height: 20),

                  // App name
                  Text(
                    'HisaabBox',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Tagline
                  Text(
                    'Smart Billing & Inventory',
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Loading indicator
                  SizedBox(
                    width: loaderSize,
                    height: loaderSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom — version ─────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(bottom: desktop ? 24.0 : 24.h),
            child: Column(
              children: [
                Text(
                  'Powered by SoftwareSnip',
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 6),
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: desktop ? 12.0 : 12.w,
                      vertical: desktop ? 4.0 : 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      AppVersion.display,
                      style: CustomTextStyle.customNato(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
