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
                    width: 120.w,
                    height: 120.h,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, _, _) =>
                            Icon(Icons.inventory_2_rounded, size: 80.sp),
                  ),

                  SizedBox(height: 20.h),

                  // App name
                  Text(
                    'HisaabBox',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Tagline
                  Text(
                    'Smart Billing & Inventory',
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Loading indicator
                  SizedBox(
                    width: 22.w,
                    height: 22.h,
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
            padding: EdgeInsets.only(bottom: 24.h),
            child: Column(
              children: [
                Text(
                  'Powered by SoftwareSnip',
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
                SizedBox(height: 6.h),
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20.r),
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
