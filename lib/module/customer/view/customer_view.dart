import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/module/customer/model/add_customer_model.dart';
import 'package:inventory/module/customer/model/all_customer_model.dart';
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
                          // Mobile autocomplete — same pattern as OrderView
                          Autocomplete<CustomerItem>(
                            optionsBuilder: (TextEditingValue tv) {
                              if (tv.text.isEmpty) {
                                return const Iterable.empty();
                              }
                              return controller.customerList.where((e) {
                                final mobile = e.mobileNo ?? '';
                                final name = (e.name ?? '').toLowerCase();
                                final q = tv.text.toLowerCase();
                                return mobile.contains(q) || name.contains(q);
                              });
                            },
                            displayStringForOption: (o) => o.mobileNo ?? '',
                            onSelected: (option) {
                              controller.setDataAsPerOptionSelected(
                                AddCustomerData(
                                  name: option.name,
                                  mobileNo: option.mobileNo,
                                  address: option.address,
                                ),
                              );
                            },
                            fieldViewBuilder: (
                              ctx,
                              textCtrl,
                              focusNode,
                              onSubmit,
                            ) {
                              return Obx(
                                () => CommonTextField(
                                  hintText: 'Mobile No',
                                  label: 'Mobile No',
                                  controller: controller.mobileController,
                                  keyboardType: TextInputType.number,
                                  inputLength: 10,
                                  validator: (no) {
                                    if (no?.isEmpty ?? false) {
                                      return 'Enter mobile no';
                                    } else if ((no?.length ?? 0) > 10) {
                                      return 'Mobile no should be 10 digit';
                                    }
                                    return null;
                                  },
                                  // suffixIcon:
                                  //     controller
                                  //             .isCustomerFetchingByMobileNumberLoading
                                  //             .value
                                  //         ? Container(
                                  //           height: 30,
                                  //           width: 40,
                                  //           color: AppColors.whiteColor,
                                  //           child: CommonProgressBar(
                                  //             size: 40,
                                  //             color: AppColors.blackColor,
                                  //           ),
                                  //         )
                                  //         : null,
                                  onChanged: (v) {
                                    textCtrl.text = v;
                                    controller.mobileController.text = v;
                                  },
                                ),
                              );
                            },
                            optionsViewBuilder: (ctx, onSelected, options) {
                              return CustomPadding(
                                paddingOption: SymmetricPadding(horizontal: 16),
                                child: Material(
                                  color: AppColors.greyColorShade100,
                                  elevation: 5,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10.r),
                                    bottomRight: Radius.circular(10.r),
                                  ),
                                  child: SizedBox(
                                    height: 150.h,
                                    child: ListView.builder(
                                      itemCount: options.length,
                                      itemBuilder: (ctx, i) {
                                        final c = options.elementAt(i);
                                        return InkWell(
                                          onTap: () => onSelected(c),
                                          child: Container(
                                            height: 40.h,
                                            margin:
                                                OnlyPadding(
                                                  left: 5,
                                                  bottom: 5,
                                                  right: 5,
                                                  top: 8,
                                                ).getPadding(),
                                            padding:
                                                OnlyPadding(
                                                  top: 5,
                                                  left: 8,
                                                  bottom: 5,
                                                ).getPadding(),
                                            decoration: BoxDecoration(
                                              color: Colors.black12,
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                            ),
                                            child: Text(
                                              c.mobileNo ?? '',
                                              style:
                                                  CustomTextStyle.customMontserrat(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          setHeight(height: 10),
                          CommonTextField(
                            hintText: 'Name',
                            label: 'Name',
                            controller: controller.nameController,
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
                            controller: controller.addressController,
                          ),
                          setHeight(height: 10),
                          CommonTextField(
                            astraIsRequred: false,
                            hintText: 'Description',
                            label: 'Description',
                            controller: controller.descriptionController,
                          ),
                          setHeight(height: 30),
                          Obx(
                            () => CommonButton(
                              isLoading: controller.isAddCustomerLoading.value,
                              label: 'Save',
                              bgColor:
                                  controller
                                          .isCustomerFetchingByMobileNumberLoading
                                          .value
                                      ? AppColors.greyColor
                                      : AppColors.blackColor,
                              onTap:
                                  controller
                                          .isCustomerFetchingByMobileNumberLoading
                                          .value
                                      ? () {}
                                      : () async {
                                        if (inventoryScanKey.currentState!
                                            .validate()) {
                                          final body = {
                                            "mobile_no":
                                                controller
                                                    .mobileController
                                                    .text,
                                            "name":
                                                controller.nameController.text,
                                            "address":
                                                controller
                                                    .addressController
                                                    .text,
                                            "description":
                                                controller
                                                    .descriptionController
                                                    .text,
                                          };
                                          controller.addCustomers(body: body);
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
                    Get.back();
                    controller.clear();
                  },
                );
              },
              child: const Icon(CupertinoIcons.add),
            ),
          ),
        ],
      ),
      appBarLabel: 'Customers',
      body: CustomPadding(
        paddingOption: SymmetricPadding(horizontal: 8.0),
        child: RefreshIndicator.adaptive(
          onRefresh: () => controller.fetchAllCustomers(),
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
                          ? CommonProgressBar(color: AppColors.blackColor)
                          : controller.customerList.isEmpty
                          ? CommonNoDataFound(message: 'No customer found')
                          : ListView.builder(
                            itemCount: controller.customerList.length,
                            itemBuilder: (context, index) {
                              final customerData =
                                  controller.customerList[index];
                              return Obx(
                                () =>
                                    (customerData.name ?? '')
                                                .toLowerCase()
                                                .contains(
                                                  controller.searchText.value,
                                                ) ||
                                            (customerData.mobileNo ?? '')
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
                                            customerData.mobileNo ?? '',
                                            style:
                                                CustomTextStyle.customOpenSans(),
                                          ),
                                        )
                                        : const SizedBox.shrink(),
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
