import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/keys/keys.dart';
import 'package:inventory/module/order_complete/controller/order_controller.dart';
import 'package:inventory/module/order_complete/widget/customer_details_mobile.dart';
import 'package:inventory/routes/route_name.dart';
import 'package:inventory/routes/routes.dart';
import '../../../common_widget/common_bottom_sheet.dart';
import '../../../common_widget/common_divider.dart';
import '../../../helper/helper.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      isleadingButtonRequired: false,
      appBarLabel: '',
      body: SingleChildScrollView(
        child: CustomPadding(
          paddingOption: SymmetricPadding(horizontal: 15.0),
          child: Column(
            children: [
              Container(
                height: 170.h,
                width: 400.w,
                decoration: BoxDecoration(
                  color: AppColors.greyColorShade100,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50.r),
                    bottomLeft: Radius.circular(50.r),
                  ),
                ),
                child: Image.asset('assets/verify.png'),
              ),
              setHeight(height: 30),
              Text(
                'ORDER COMPLETED',
                style: CustomTextStyle.customMontserrat(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontSize: 20,
                ),
              ),
              setHeight(height: 20),
              Text(
                '${controller.data.soldAt} ${controller.data.time}',
                style: CustomTextStyle.customMontserrat(letterSpacing: 1),
              ),
              setHeight(height: 10),
              CommonDivider(
                endIndent: 50,
                indent: 50,
                thickness: 1.5,
                color: AppColors.blackColor,
              ),
              setHeight(height: 20),
              Text(
                'TOTAL AMOUNT',
                style: CustomTextStyle.customMontserrat(letterSpacing: 0.5),
              ),
              setHeight(height: 10),
              RichText(
                text: TextSpan(
                  text: '\u{20B9} ',
                  style: CustomTextStyle.customPoppin(fontSize: 25),
                  children: [
                    TextSpan(
                      text: '${controller.data.finalAmount}',
                      style: CustomTextStyle.customNato(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ),
              setHeight(height: 20),
              InkWell(
                onTap: () {
                  commonBottomSheet(
                    child: CustomPadding(
                      paddingOption: AllPadding(all: 8.0),
                      child: Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        key: inventoryScanKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            setHeight(height: 10),
                            CustomerDetailsMobileAutoCompleteWidget(
                              controller: controller,
                            ),
                            setHeight(height: 20),
                            CommonTextField(
                              hintText: 'Name',
                              label: 'Name',
                              controller: controller.name,
                              validator: (add) {
                                if (add?.isEmpty ?? false) {
                                  return 'Enter name';
                                }
                                return null;
                              },
                            ),
                            setHeight(height: 20),
                            CommonTextField(
                              astraIsRequred: false,
                              hintText: 'Address',
                              label: 'Address',
                              controller: controller.address,
                              // validator: (add) {
                              //   if (add?.isEmpty ?? false) {
                              //     return 'Enter address';
                              //   }
                              //   return null;
                              // },
                            ),
                            setHeight(height: 30),
                            Obx(
                              () => CommonButton(
                                isLoading:
                                    controller
                                        .saveCustomerWithInvoiceLoading
                                        .value,
                                label: 'Save & Print',
                                onTap: () async {
                                  if (inventoryScanKey.currentState!
                                      .validate()) {
                                    var res = await controller
                                        .saveCustomerWithInvoice(
                                          invoice: controller.data,
                                        );
                                    if (res == true) {
                                      Get.back();
                                      showMessage(
                                        message: "Customer added with invoice",
                                      );
                                      AppRoutes.navigateRoutes(
                                        routeName:
                                            AppRouteName.invoicePrintView,
                                        data: controller.data,
                                      );
                                    } else {
                                      showMessage(
                                        message: somethingWentMessage,
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                            setHeight(height: 80),
                          ],
                        ),
                      ),
                    ),
                    label: addCustomer,
                    onPressed: () {
                      controller.clear();
                      Get.back();
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, color: AppColors.deepPurple),
                    setWidth(width: 20),
                    Text(
                      addCustomer,
                      style: CustomTextStyle.customMontserrat(
                        letterSpacing: 0.5,
                        color: AppColors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              setHeight(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CommonButton(
                    width: 150,
                    label: 'Home',
                    onTap: () {
                      AppRoutes.navigateRoutes(
                        routeName: AppRouteName.bottomNavigation,
                      );
                    },
                  ),
                  CommonButton(
                    bgColor: AppColors.redColor,
                    textColor: AppColors.whiteColor,
                    width: 150,
                    label: 'Print',
                    onTap: () {
                      AppRoutes.navigateRoutes(
                        routeName: AppRouteName.invoicePrintView,
                        data: controller.data,
                      );
                    },
                  ),
                ],
              ),
              setHeight(height: 30),
              RichText(
                text: TextSpan(
                  text: '⭐ Thank you for choosing ',
                  style: CustomTextStyle.customPoppin(
                    fontSize: 16,
                    color: AppColors.greyColor,
                  ),
                  children: [
                    TextSpan(
                      text: 'HISAB BOX',
                      style: CustomTextStyle.customMontserrat(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
