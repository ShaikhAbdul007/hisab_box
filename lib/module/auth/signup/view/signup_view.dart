import 'dart:io';
import 'package:inventory/responsive_layout/dimension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/helper/logger.dart';
import 'package:inventory/module/auth/signup/widget/shop_address_widget.dart';
import 'package:inventory/routes/routes.dart';
import '../../../../common_widget/colors.dart';
import '../../../../helper/app_message.dart';
import '../../../../helper/textstyle.dart';
import '../../../../keys/keys.dart';
import '../../../../routes/route_name.dart';
import '../controller/signup_controller.dart';
import '../widget/shop_details_widget.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  Future<bool> _handleBack() async {
    if (controller.isShopDetailFilled.value) {
      controller.isShopDetailFilled.value = false;
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              width: 560,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    _buildStepIndicator(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: Form(
                        key: shopAddress,
                        child: controller.isShopDetailFilled.value
                            ? Obx(
                                () => ShopAddress(
                                  notifyParent: (v) {
                                    controller.shopType.text = v;
                                    AppLogger.info(v);
                                  },
                                  profileImage: controller.profileImage.value ??
                                      File(controller.profileImage.value?.path ?? ''),
                                  onPressed: () => controller.pickImage(),
                                  shopName: controller.name,
                                  address: controller.address,
                                  city: controller.city,
                                  state: controller.state,
                                  pincode: controller.pinCode,
                                ),
                              )
                            : ShopDetails(
                                password: controller.password,
                                confirmpassword: controller.confirmpassword,
                                mobileNo: controller.mobileNo,
                                email: controller.email,
                                alternateMobileNo: controller.alternateMobileNo,
                                obscureText: controller.obscureTextValue.value,
                                onTap: () {
                                  controller.togglePasswordVisibility();
                                },
                              ),
                      ),
                    ),
                    _buildBottomActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleBack();
        if (shouldPop) {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Obx(
            () => Column(
              children: [
                // ── Top header ──────────────────────────────────────────
                _buildHeader(context),

                // ── Step indicator ──────────────────────────────────────
                _buildStepIndicator(),

                // ── Scrollable form ─────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 8.h,
                    ),
                    child: Form(
                      key: shopAddress,
                      child:
                          controller.isShopDetailFilled.value
                              ? Obx(
                                () => ShopAddress(
                                  notifyParent: (v) {
                                    controller.shopType.text = v;
                                    AppLogger.info(v);
                                  },
                                  profileImage:
                                      controller.profileImage.value ??
                                      File(
                                        controller.profileImage.value?.path ??
                                            '',
                                      ),
                                  onPressed: () => controller.pickImage(),
                                  shopName: controller.name,
                                  address: controller.address,
                                  city: controller.city,
                                  state: controller.state,
                                  pincode: controller.pinCode,
                                ),
                              )
                              : ShopDetails(
                                password: controller.password,
                                confirmpassword: controller.confirmpassword,
                                mobileNo: controller.mobileNo,
                                email: controller.email,
                                alternateMobileNo: controller.alternateMobileNo,
                                obscureText: controller.obscureTextValue.value,
                                onTap: () {
                                  controller.togglePasswordVisibility();
                                },
                              ),
                    ),
                  ),
                ),

                // ── Bottom action area ───────────────────────────────────
                _buildBottomActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final desktop = isDesktop(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        desktop ? 20.0 : 20.w,
        desktop ? 16.0 : 16.h,
        desktop ? 20.0 : 20.w,
        desktop ? 20.0 : 20.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: desktop
            ? const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () async {
              final shouldPop = await _handleBack();
              if (shouldPop) Get.back();
            },
            child: Container(
              width: desktop ? 40.0 : 40.w,
              height: desktop ? 40.0 : 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(desktop ? 12.0 : 12.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: desktop ? 16.0 : 16.sp,
                color: AppColors.blackColor,
              ),
            ),
          ),
          SizedBox(width: desktop ? 14.0 : 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.isShopDetailFilled.value
                        ? 'Shop Details'
                        : 'Create Account',
                    style: CustomTextStyle.customPoppin(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  createAccountSubtitle,
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 12,
                    color: AppColors.greyColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step indicator ────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    final desktop = isDesktop(Get.context!);
    return Obx(
      () => Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
          desktop ? 24.0 : 24.w,
          0,
          desktop ? 24.0 : 24.w,
          desktop ? 16.0 : 16.h,
        ),
        child: Row(
          children: [
            _stepDot(
              label: 'Account Info',
              isActive: true,
              isDone: controller.isShopDetailFilled.value,
            ),
            _stepLine(controller.isShopDetailFilled.value),
            _stepDot(
              label: 'Shop Details',
              isActive: controller.isShopDetailFilled.value,
              isDone: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepDot({
    required String label,
    required bool isActive,
    required bool isDone,
  }) {
    final desktop = isDesktop(Get.context!);
    final Color activeColor = AppColors.blackColor;
    final Color inactiveColor = Colors.grey.shade300;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: desktop ? 28.0 : 28.w,
            height: desktop ? 28.0 : 28.h,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: desktop ? 14.0 : 14.sp,
                    )
                  : Icon(
                      isActive
                          ? Icons.radio_button_checked_rounded
                          : Icons.circle_outlined,
                      color: isActive ? Colors.white : Colors.grey.shade400,
                      size: desktop ? 14.0 : 14.sp,
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: CustomTextStyle.customNato(
              fontSize: 10,
              color: isActive ? AppColors.blackColor : AppColors.greyColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepLine(bool isActive) {
    final desktop = isDesktop(Get.context!);
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: desktop ? 18.0 : 18.h),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: desktop ? 2.0 : 2.h,
          decoration: BoxDecoration(
            color: isActive ? AppColors.blackColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(desktop ? 2.0 : 2.r),
          ),
        ),
      ),
    );
  }

  // ── Bottom actions ────────────────────────────────────────────────────────
  Widget _buildBottomActions() {
    final desktop = isDesktop(Get.context!);
    return Container(
      padding: EdgeInsets.fromLTRB(
        desktop ? 24.0 : 24.w,
        desktop ? 16.0 : 16.h,
        desktop ? 24.0 : 24.w,
        desktop ? 24.0 : 24.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: desktop
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary action button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: desktop ? 52.0 : 52.h,
              child: ElevatedButton(
                onPressed:
                    controller.signUpLoading.value
                        ? null
                        : () async {
                          if (!controller.isShopDetailFilled.value) {
                            if (shopAddress.currentState!.validate()) {
                              controller.isShopDetailFilled.value = true;
                            }
                          } else {
                            if (shopAddress.currentState!.validate()) {
                              await controller.signUpUser();
                            }
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blackColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(desktop ? 14.0 : 14.r),
                  ),
                ),
                child:
                    controller.signUpLoading.value
                        ? SizedBox(
                          width: desktop ? 22.0 : 22.w,
                          height: desktop ? 22.0 : 22.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                        : Text(
                          controller.isShopDetailFilled.value
                              ? 'Save & Continue'
                              : 'Continue',
                          style: CustomTextStyle.customRaleway(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Login link
          GestureDetector(
            onTap: () {
              AppRoutes.navigateRoutes(routeName: AppRouteName.login);
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: alreadyHaveAccount,
                style: CustomTextStyle.customOpenSans(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: questionMark,
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  TextSpan(
                    text: ' $login',
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
