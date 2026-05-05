import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';
import 'package:pinput/pinput.dart';
import '../../../../helper/app_message.dart';
import '../../../../keys/keys.dart';
import '../controller/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: SafeArea(
        child: Form(
          key: loginkey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final topHeight = constraints.maxHeight * 0.42;
              final bottomHeight = constraints.maxHeight * 0.58;
              return Column(
                children: [
                  // ── Dark top section ───────────────────────────────
                  SizedBox(height: topHeight, child: _buildTopSection()),
                  // ── White bottom card ──────────────────────────────
                  SizedBox(height: bottomHeight, child: _buildBottomCard()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Top dark section ────────────────────────────────────────────────────────
  Widget _buildTopSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 20.h, 28.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo badge
          Container(
            width: 52.w,
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/hisabboxlogo.png',
                width: 30.w,
                height: 30.h,
                color: Colors.white,
                errorBuilder:
                    (_, _, _) => Icon(
                      CupertinoIcons.cube_box_fill,
                      color: Colors.white,
                      size: 26.sp,
                    ),
              ),
            ),
          ),

          const Spacer(),

          Text(
            welcomeBack,
            style: CustomTextStyle.customPoppin(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            backtoAppName,
            style: CustomTextStyle.customPoppin(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            loginSubtitle,
            style: CustomTextStyle.customOpenSans(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ── White bottom card ───────────────────────────────────────────────────────
  Widget _buildBottomCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36.r),
          topRight: Radius.circular(36.r),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(28.w, 20.h, 28.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // ── Email field ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CommonTextField(
                textCapitalization: TextCapitalization.none,
                hintText: 'your@email.com',
                label: 'Email Address',
                controller: controller.email,
                marginPadding: EdgeInsets.zero,
                suffixIcon: CustomPadding(
                  paddingOption: OnlyPadding(right: 14),
                  child: Icon(
                    CupertinoIcons.mail_solid,
                    size: 18.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
                validator: (emailValue) {
                  if (emailValue!.isEmpty) return emptyEmail;
                  if (!GetUtils.isEmail(emailValue)) return invalidEmail;
                  return null;
                },
              ),
            ),

            SizedBox(height: 22.h),

            // ── Send OTP button ──────────────────────────────────────
            Obx(
              () => GestureDetector(
                onTap:
                    controller.loginLoading.value
                        ? null
                        : () async {
                          if (loginkey.currentState!.validate()) {
                            bool otpRes = await controller.sendOtp();
                            if (otpRes) {
                              controller.startResendTimer();
                              _showOtpBottomSheet();
                            }
                          }
                        },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 54.h,
                  decoration: BoxDecoration(
                    color:
                        controller.loginLoading.value
                            ? Colors.grey.shade300
                            : AppColors.blackColor,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow:
                        controller.loginLoading.value
                            ? []
                            : [
                              BoxShadow(
                                color: AppColors.blackColor.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                  ),
                  child: Center(
                    child:
                        controller.loginLoading.value
                            ? SizedBox(
                              width: 22.w,
                              height: 22.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  sendOTP,
                                  style: CustomTextStyle.customRaleway(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Container(
                                  width: 28.w,
                                  height: 28.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // ── Divider ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.grey.shade300, thickness: 1),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Text(
                    'or',
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(color: Colors.grey.shade300, thickness: 1),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // ── Sign up link ─────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap:
                    () => AppRoutes.navigateRoutes(
                      routeName: AppRouteName.signup,
                    ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: dontHaveAccount,
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
                        text: createAccount,
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
            ),
          ],
        ),
      ),
    );
  }

  // ── OTP bottom sheet ────────────────────────────────────────────────────────
  void _showOtpBottomSheet() {
    // Use Get.find so Obx widgets inside the bottom sheet
    // (which runs in a separate overlay route) can resolve the controller.
    final LoginController c = Get.find<LoginController>();

    final defaultPinTheme = PinTheme(
      width: 46.w,
      height: 52.h,
      textStyle: CustomTextStyle.customPoppin(
        fontSize: 18,
        color: AppColors.blackColor,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      color: Colors.white,
      border: Border.all(color: AppColors.blackColor, width: 2),
      borderRadius: BorderRadius.circular(12.r),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: AppColors.blackColor,
      border: Border.all(color: AppColors.blackColor, width: 1.5),
      borderRadius: BorderRadius.circular(12.r),
    );

    commonBottomSheet(
      label: 'OTP Verification',
      onPressed: () => Get.back(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Lock icon ────────────────────────────────────────────
            Container(
              width: 60.w,
              height: 60.h,
              decoration: const BoxDecoration(
                color: AppColors.blackColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.lock_shield_fill,
                size: 26.sp,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 14.h),

            Text(
              'Enter Verification Code',
              style: CustomTextStyle.customPoppin(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.blackColor,
              ),
            ),

            SizedBox(height: 6.h),

            Text(
              'We sent a 6-digit OTP to\n${c.email.text}',
              textAlign: TextAlign.center,
              style: CustomTextStyle.customOpenSans(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),

            SizedBox(height: 24.h),

            // ── PIN input ────────────────────────────────────────────
            Pinput(
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme.copyWith(
                textStyle: CustomTextStyle.customPoppin(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              closeKeyboardWhenCompleted: true,
              length: 6,
              keyboardType: TextInputType.number,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              onCompleted: (pin) => c.verifyOtp(otp: pin),
            ),

            SizedBox(height: 24.h),

            // ── Verify button ────────────────────────────────────────
            Obx(
              () => GestureDetector(
                onTap:
                    c.verifyLoading.value
                        ? null
                        : () => c.verifyOtp(otp: '123456'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 52.h,
                  decoration: BoxDecoration(
                    color:
                        c.verifyLoading.value
                            ? Colors.grey.shade300
                            : AppColors.blackColor,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow:
                        c.verifyLoading.value
                            ? []
                            : [
                              BoxShadow(
                                color: AppColors.blackColor.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                  ),
                  child: Center(
                    child:
                        c.verifyLoading.value
                            ? SizedBox(
                              width: 22.w,
                              height: 22.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : Text(
                              'Verify OTP',
                              style: CustomTextStyle.customRaleway(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 18.h),

            // ── Resend row ───────────────────────────────────────────
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code?  ",
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  c.canResend.value
                      ? GestureDetector(
                        onTap: () async {
                          await c.sendOtp();
                          c.startResendTimer();
                        },
                        child: Text(
                          'Resend',
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackColor,
                          ),
                        ),
                      )
                      : Text(
                        'Resend in ${_formatTimer(c.resendSeconds.value)}',
                        style: CustomTextStyle.customOpenSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Timer formatter ─────────────────────────────────────────────────────────
  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // kept for backward-compat
  Widget otpVerificationBottomSheet() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: CustomTextStyle.customPoppin(
        fontSize: 14,
        color: AppColors.blackColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greenColor),
        borderRadius: BorderRadius.circular(15),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.greenColor),
      borderRadius: BorderRadius.circular(15),
    );
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.greenAccentColor,
      ),
    );
    return Container(
      margin: const EdgeInsets.all(10),
      child: Pinput(
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        closeKeyboardWhenCompleted: true,
        length: 6,
        keyboardType: TextInputType.number,
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        showCursor: true,
        onCompleted: (pin) => controller.verifyOtp(otp: pin),
      ),
    );
  }
}
