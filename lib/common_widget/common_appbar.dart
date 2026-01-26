import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/helper.dart';

import '../helper/app_message.dart';
import '../helper/textstyle.dart';

class CommonAppbar extends StatelessWidget {
  final String appBarLabel;
  final Color? backgroundColor;
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
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // onPopInvokedWithResult: (didPop, backpop) async {
      //   if (!didPop) {
      //     await handleBack(context);
      //   }
      // },
      child: Scaffold(
        backgroundColor: backgroundColor ?? AppColors.greyColorShade100,
        persistentFooterButtons: persistentFooterButtons,
        persistentFooterDecoration: BoxDecoration(),
        appBar: AppBar(
          actionsPadding: OnlyPadding(right: 20).getPadding(),

          actions: [
            firstActionChild ?? Container(),
            setWidth(width: 15),
            secondActionChild ?? Container(),
          ],
          surfaceTintColor: AppColors.greyColorShade100,
          backgroundColor: AppColors.greyColorShade100,
          title: Text(
            appBarLabel,
            style: CustomTextStyle.customNato(fontSize: 16),
          ),
          leading:
              isleadingButtonRequired
                  ? IconButton(
                    onPressed: () async {
                      customMessageOrErrorPrint(message: appBarLabel);
                      var cache = CacheManager();
                      // var cacheProductList =
                      //     await cache.retrieveCartProductList();
                      if (appBarLabel == sellingProduct) {
                        customMessageOrErrorPrint(message: 'sellingProduct');
                        cache.removeCartProductList();
                      }
                      customMessageOrErrorPrint(message: 'back pressed');
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
