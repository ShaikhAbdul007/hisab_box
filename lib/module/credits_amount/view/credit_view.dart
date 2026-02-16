import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/search.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/textstyle.dart';
import '../../../helper/helper.dart';
import '../controller/credit_controller.dart';

class CreditView extends GetView<CredtiController> {
  const CreditView({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      isleadingButtonRequired: false,
      appBarLabel: "Credits",
      body: CustomPadding(
        paddingOption: SymmetricPadding(horizontal: 8.0),
        child: RefreshIndicator.adaptive(
          onRefresh: () => controller.fetchCreditCustomers(),
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
                  hintText: 'search credit',
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
                          ? CommonNodatafound(message: 'No credit found')
                          : ListView.builder(
                            itemCount: controller.customerDetailList.length,
                            itemBuilder: (context, index) {
                              var customerData =
                                  controller.customerDetailList[index];
                              final totalCredit = controller
                                  .calculateTotalCredit(customerData);
                              return Obx(
                                () =>
                                    customerData.name!.toLowerCase().contains(
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
                                            totalCredit > 0
                                                ? "₹ $totalCredit"
                                                : "₹ 0",
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
