import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/size.dart';

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
        backgroundColor: backgroundColor ?? AppColors.greyColorShade100,
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
            style: CustomTextStyle.customNato(fontSize: 18),
          ),
          //  automaticallyImplyLeading: true,
          leading:
              isleadingButtonRequired
                  ? IconButton(
                    onPressed: () async {
                      var cache = CacheManager();
                      var cacheProductList =
                          await cache.retrieveCartProductList();
                      if (appBarLabel == sellingProduct &&
                          cacheProductList.isNotEmpty) {
                        cache.removeCartProductList();
                      }
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
