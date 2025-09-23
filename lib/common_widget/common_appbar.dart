import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';

import '../helper/textstyle.dart';

class CommonAppbar extends StatelessWidget {
  final String appBarLabel;
  final Widget body;
  final Widget? firstActionChild;
  final Widget? secondActionChild;
  final bool isleadingButtonRequired;
  final Future<void> Function(BuildContext context)? onBack;
  final List<Widget>? persistentFooterButtons;
  const CommonAppbar({
    super.key,
    required this.appBarLabel,
    required this.body,
    this.isleadingButtonRequired = true,
    this.firstActionChild,
    this.secondActionChild,
    this.onBack,
    this.persistentFooterButtons,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> handleBack(BuildContext context) async {
      if (onBack != null) {
        await onBack!(context);
      }
      Get.back();
    }

    return PopScope(
      canPop: false,
      // onPopInvokedWithResult: (didPop, backpop) async {
      //   if (!didPop) {
      //     await handleBack(context);
      //   }
      // },
      child: Scaffold(
        backgroundColor: AppColors.greyColorShade100,
        persistentFooterButtons: persistentFooterButtons,
        appBar: AppBar(
          actionsPadding: EdgeInsets.only(right: 20),
          actions: [
            firstActionChild ?? Container(),
            setWidth(width: 15),
            secondActionChild ?? Container(),
          ],

          backgroundColor: AppColors.greyColorShade100,
          title: Text(
            appBarLabel,
            style: CustomTextStyle.customNato(fontSize: 20),
          ),
          automaticallyImplyLeading: true,
          leading:
              isleadingButtonRequired
                  ? IconButton(
                    onPressed: () {
                      print('back pressed');
                      Get.back(result: true);
                    },
                    icon: Icon(CupertinoIcons.back),
                  )
                  : null,
        ),

        body: body,
      ),
    );
  }
}
