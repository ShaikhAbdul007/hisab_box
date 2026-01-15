import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/module/sell/model/print_model.dart';

import '../../../common_widget/colors.dart';
import '../../../common_widget/common_bottom_sheet.dart';
import '../../../common_widget/common_container.dart';
import '../../../common_widget/common_nodatafound.dart';
import '../../../common_widget/common_padding.dart';
import '../../../common_widget/common_progressbar.dart';
import '../../../common_widget/search.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../../../helper/textstyle.dart';
import '../../../keys/keys.dart';
import '../../order_complete/widget/customer_details_mobile.dart';
import '../controller/customer_controller.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      isleadingButtonRequired: false,
      firstActionChild: Row(
        children: [
          CommonContainer(
            height: 40,
            width: 50,
            radius: 10,
            color: AppColors.whiteColor,
            child: InkWell(
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
                            controller: controller.orderController,
                          ),
                          setHeight(height: 10),
                          CommonTextField(
                            hintText: 'Name',
                            label: 'Name',
                            controller: controller.orderController.name,
                            validator: (add) {
                              if (add?.isEmpty ?? false) {
                                return 'Enter name';
                              }
                              return null;
                            },
                          ),
                          setHeight(height: 10),
                          CommonTextField(
                            astraIsRequred: false,
                            hintText: 'Address',
                            label: 'Address',
                            controller: controller.orderController.address,
                            // validator: (add) {
                            //   if (add?.isEmpty ?? false) {
                            //     return 'Enter address';
                            //   }
                            //   return null;
                            // },
                          ),
                          setHeight(height: 10),
                          CommonTextField(
                            astraIsRequred: false,

                            hintText: 'Description',
                            label: 'Description',
                            controller: controller.orderController.description,
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
                                      .orderController
                                      .saveCustomerWithInvoiceLoading
                                      .value,
                              label: 'Save',
                              onTap: () async {
                                if (inventoryScanKey.currentState!.validate()) {
                                  var res = await controller.orderController
                                      .saveCustomerWithInvoice(
                                        invoice: PrintInvoiceModel(),
                                      );
                                  if (res == true) {
                                    controller.fetchAllCustomers();
                                    Get.back();
                                    controller.orderController.clear();
                                    showMessage(message: "Customer added");
                                  } else {
                                    showMessage(message: somethingWentMessage);
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
              child: Icon(CupertinoIcons.add),
            ),
          ),
        ],
      ),
      appBarLabel: 'Customers',
      body: CustomPadding(
        paddingOption: SymmetricPadding(horizontal: 8.0),
        child: RefreshIndicator.adaptive(
          onRefresh: () {
            return controller.fetchAllCustomers();
          },
          child: Column(
            children: [
              setHeight(height: 10),
              Expanded(
                flex: 2,
                child: CommonSearch(
                  icon: Obx(
                    () => InkWell(
                      onTap:
                          controller.searchText.value.isNotEmpty
                              ? () {
                                controller.clear();
                                unfocus();
                              }
                              : null,
                      child: Icon(
                        controller.searchText.value.isNotEmpty
                            ? CupertinoIcons.clear
                            : CupertinoIcons.search,
                      ),
                    ),
                  ),
                  label: 'Search',
                  hintText: 'search customer',
                  controller: controller.searchController,
                  onChanged: (val) => controller.searchProduct(val),
                ),
              ),
              Expanded(
                flex: 20,
                child: Obx(
                  () =>
                      controller.customDataLoading.value
                          ? CommonProgressbar(color: AppColors.blackColor)
                          : controller.customerDetailList.isEmpty
                          ? CommonNodatafound(message: 'No customer found')
                          : ListView.builder(
                            itemCount: controller.customerDetailList.length,
                            itemBuilder: (context, index) {
                              var customerData =
                                  controller.customerDetailList[index];
                              return Obx(
                                () =>
                                    customerData.name!.toLowerCase().contains(
                                              controller.searchText.value,
                                            ) ||
                                            customerData.mobile!
                                                .toLowerCase()
                                                .contains(
                                                  controller.searchText.value,
                                                )
                                        ? ListTile(
                                          title: Text(
                                            customerData.name ?? '',
                                            style:
                                                CustomTextStyle.customMontserrat(),
                                          ),
                                          subtitle: Text(
                                            customerData.address ?? '',
                                            style:
                                                CustomTextStyle.customMontserrat(),
                                          ),
                                          trailing: Text(
                                            customerData.mobile ?? '',
                                            style:
                                                CustomTextStyle.customOpenSans(),
                                          ),
                                        )
                                        : Container(),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
