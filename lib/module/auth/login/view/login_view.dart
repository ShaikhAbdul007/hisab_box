import 'package:inventory/responsive_layout/dimension.dart';
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
  final showOtpView = false.obs;

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Row(
          children: [
            // Left pane: Graphics illustration
            Expanded(
              child: Container(
                color: AppColors.blackColor,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo badge
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.cube_box_fill,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Welcome to HisaabBox',
                          style: CustomTextStyle.customPoppin(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Smart Billing & Inventory suite designed for fast-growing businesses. Keep track of sales, purchase histories, and credit ledger settled in real time.',
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Simulated stats cards for high visual impact
                        _buildStatsCards(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Right pane: Login form / OTP form card
            Container(
              width: 500,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Center(
                child: SingleChildScrollView(
                  child: Obx(() {
                    if (showOtpView.value) {
                      return _buildDesktopOtpCard(context);
                    }
                    return _buildDesktopLoginCard(context);
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
              onCompleted: (pin) {
                c.otp.value = pin;
                c.verifyOtp(otp: pin);
              },
            ),

            SizedBox(height: 24.h),

            // ── Verify button ────────────────────────────────────────
            Obx(
              () => GestureDetector(
                onTap:
                    c.verifyLoading.value
                        ? null
                        : () => c.verifyOtp(otp: c.otp.value),
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

  Widget _buildStatsCards() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.graph_square_fill,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Billing Done',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹4,89,320.00',
                    style: CustomTextStyle.customPoppin(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.person_2_fill,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Customers Directory',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2,480 Users',
                    style: CustomTextStyle.customPoppin(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLoginCard(BuildContext context) {
    return Form(
      key: loginkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign In',
            style: CustomTextStyle.customPoppin(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your registered email address to receive a secure login OTP code.',
            style: CustomTextStyle.customOpenSans(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 36),

          // Email input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(
                  CupertinoIcons.mail_solid,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
              validator: (emailValue) {
                if (emailValue == null || emailValue.isEmpty) return emptyEmail;
                if (!GetUtils.isEmail(emailValue)) return invalidEmail;
                return null;
              },
            ),
          ),
          const SizedBox(height: 30),

          // Action Button
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
                            showOtpView.value = true;
                          }
                        }
                      },
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color:
                      controller.loginLoading.value
                          ? Colors.grey.shade300
                          : AppColors.blackColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child:
                      controller.loginLoading.value
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
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
                              const SizedBox(width: 10),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade200)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'or',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade200)),
            ],
          ),
          const SizedBox(height: 24),

          // Register option
          Center(
            child: GestureDetector(
              onTap:
                  () =>
                      AppRoutes.navigateRoutes(routeName: AppRouteName.signup),
              child: RichText(
                text: TextSpan(
                  text: dontHaveAccount,
                  style: CustomTextStyle.customOpenSans(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  children: [
                    TextSpan(
                      text: '  $signup',
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
    );
  }

  Widget _buildDesktopOtpCard(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 54,
      textStyle: CustomTextStyle.customPoppin(
        fontSize: 18,
        color: AppColors.blackColor,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      color: Colors.white,
      border: Border.all(color: AppColors.blackColor, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: AppColors.blackColor,
      border: Border.all(color: AppColors.blackColor, width: 1.5),
      borderRadius: BorderRadius.circular(12),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back to email button
        GestureDetector(
          onTap: () {
            showOtpView.value = false;
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.arrow_left,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Back to Email Address',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        Text(
          'Verification Code',
          style: CustomTextStyle.customPoppin(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please enter the 6-digit OTP code sent to your email:\n${controller.email.text}',
          style: CustomTextStyle.customOpenSans(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 36),

        // OTP inputs
        Center(
          child: Pinput(
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme.copyWith(
              textStyle: CustomTextStyle.customPoppin(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            length: 6,
            keyboardType: TextInputType.number,
            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
            showCursor: true,
            onCompleted: (pin) {
              controller.otp.value = pin;
              controller.verifyOtp(otp: pin);
            },
          ),
        ),
        const SizedBox(height: 36),

        // Verify button
        Obx(
          () => GestureDetector(
            onTap:
                controller.verifyLoading.value
                    ? null
                    : () => controller.verifyOtp(otp: controller.otp.value),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color:
                    controller.verifyLoading.value
                        ? Colors.grey.shade300
                        : AppColors.blackColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child:
                    controller.verifyLoading.value
                        ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Verify & Login',
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
        const SizedBox(height: 24),

        // Resend Timer Row
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
              controller.canResend.value
                  ? GestureDetector(
                    onTap: () async {
                      await controller.sendOtp();
                      controller.startResendTimer();
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
                    'Resend in ${_formatTimer(controller.resendSeconds.value)}',
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
    );
  }
}
