import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';

class UnknownRoute extends StatelessWidget {
  const UnknownRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/unknwon_route.png'),
          setHeight(height: 20),
          Text(
            'No found 404',
            style: CustomTextStyle.customRaleway(fontSize: 25),
          ),
          setHeight(height: 20),
          CommonButton(
            label: 'Back',
            onTap: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
