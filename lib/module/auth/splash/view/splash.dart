import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/auth/splash/controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.movetoNextScreen();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/hisabboxlogo.png',
                    height: 250,
                    width: 200,
                  ),
                  SizedBox(height: 20),
                  CommonProgressbar(size: 50.0, color: AppColors.blackColor),
                ],
              ),
            ),
          ),
          CustomPadding(
            paddingOption: OnlyPadding(bottom: 20),
            child: Text(
              'App version: 1.0.0',
              style: CustomTextStyle.customOpenSans(),
            ),
          ),
        ],
      ),
    );
  }
}
