import 'package:flutter/material.dart';
import 'package:inventory/keys/keys.dart';

import '../controller/signup_controller.dart';
import '../widget/shop_details_widget.dart';

class ShopDetailsView extends StatelessWidget {
  final SignupController? controller;
  const ShopDetailsView({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: shopDetails,
      child: ShopDetails(
        password: controller!.password,
        confirmpassword: controller!.confirmpassword,
        mobileNo: controller!.mobileNo,
        email: controller!.email,
        alternateMobileNo: controller!.alternateMobileNo,
        obscureText: controller!.obscureTextValue.value,
        onTap: () {
          controller!.setobscureTextValue();
        },
      ),
    );
  }
}
