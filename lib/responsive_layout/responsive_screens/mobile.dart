import 'package:flutter/material.dart';

import '../../common_widget/colors.dart';

class Mobile extends StatelessWidget {
  final Widget? body;
  const Mobile({super.key, this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      //   drawer: CustomDrawer(),
      body: body ?? Container(),
      //  persistentFooterButtons: [Footer(isMobile: true)],
    );
  }
}
