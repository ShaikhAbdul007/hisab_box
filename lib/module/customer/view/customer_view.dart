import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/appbar_add_button.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/module/customer/widget/customer_view_mobile_no_auto_complete_widget.dart';
import '../../../common_widget/colors.dart';
import '../../../common_widget/common_bottom_sheet.dart';
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
      appBarLabel: 'Customers',
      firstActionChild: AppBarAddButton(
        tooltip: 'Add Customer',
        onTap: () => _showAddCustomerSheet(),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => controller.fetchAllCustomers(),
        child: Column(
          children: [
            // ── Search bar ─────────────────────────────────────────────
            Padding(
              padding:
                  SymmetricPadding(horizontal: 12, vertical: 10).getPadding(),
              child: CommonSearch(
                icon: Obx(
                  () =>
                      controller.searchText.value.isNotEmpty
                          ? InkWell(
                            onTap: () {
                              controller.clear();
                              unfocus();
                            },
                            child: Icon(
                              CupertinoIcons.clear_circled_solid,
                              size: 20.sp,
                              color: AppColors.blackColor,
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
                label: 'Search',
                hintText: 'Search by name or mobile',
                controller: controller.searchController,
                onChanged: (val) => controller.searchProduct(val),
              ),
            ),

            // ── List ───────────────────────────────────────────────────
            Expanded(
              child: Obx(
                () =>
                    controller.customDataLoading.value
                        ? const CommonProgressBar(color: AppColors.blackColor)
                        : controller.customerList.isEmpty
                        ? CommonNoDataFound(message: 'No customers found')
                        : ListView.builder(
                          padding:
                              SymmetricPadding(
                                horizontal: 12,
                                vertical: 4,
                              ).getPadding(),
                          itemCount: controller.customerList.length,
                          itemBuilder: (context, index) {
                            final customerData = controller.customerList[index];
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
                                      ? _CustomerCard(
                                        name: customerData.name ?? '',
                                        mobile: customerData.mobileNo ?? '',
                                        address: customerData.address ?? '',
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
    );
  }

  void _showAddCustomerSheet() {
    commonBottomSheet(
      label: addCustomer,
      onPressed: () {
        Get.back();
        controller.clear();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: inventoryScanKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Info banner ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blackColor.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.person_add_solid,
                      size: 18.sp,
                      color: AppColors.blackColor,
                    ),
                    setWidth(width: 10),
                    Text(
                      'Fill in customer details below',
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
              setHeight(height: 14),
              CustomerViewDetailsMobileAutoCompleteWidget(
                controller: controller,
              ),
              setHeight(height: 10),
              CommonTextField(
                hintText: 'Full name',
                label: 'Name',
                controller: controller.nameController,
                validator: (add) {
                  if (add?.isEmpty ?? false) return 'Enter name';
                  return null;
                },
              ),
              setHeight(height: 10),
              CommonTextField(
                astraIsRequred: false,
                hintText: 'Street, City',
                label: 'Address',
                controller: controller.addressController,
              ),
              setHeight(height: 10),
              CommonTextField(
                astraIsRequred: false,
                hintText: 'Optional note',
                label: 'Description',
                controller: controller.descriptionController,
              ),
              setHeight(height: 20),
              Obx(
                () => CommonButton(
                  isLoading: controller.isAddCustomerLoading.value,
                  label: 'Save Customer',
                  bgColor:
                      controller.isCustomerFetchingByMobileNumberLoading.value
                          ? AppColors.greyColor
                          : AppColors.blackColor,
                  onTap:
                      controller.isCustomerFetchingByMobileNumberLoading.value
                          ? () {}
                          : () async {
                            if (inventoryScanKey.currentState!.validate()) {
                              final body = {
                                'mobile_no': controller.mobileController.text,
                                'name': controller.nameController.text,
                                'address': controller.addressController.text,
                                'description':
                                    controller.descriptionController.text,
                              };
                              controller.addCustomers(body: body);
                            }
                          },
                ),
              ),
              setHeight(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Customer Card ─────────────────────────────────────────────────────────────
class _CustomerCard extends StatelessWidget {
  final String name;
  final String mobile;
  final String address;

  const _CustomerCard({
    required this.name,
    required this.mobile,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    // Initials from name
    final parts = name.trim().split(' ');
    final initials =
        parts.length >= 2
            ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
            : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar circle with initials
          Container(
            width: 46.w,
            height: 46.h,
            decoration: BoxDecoration(
              color: AppColors.blackColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: CustomTextStyle.customPoppin(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          setWidth(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: CustomTextStyle.customPoppin(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (address.isNotEmpty) ...[
                  setHeight(height: 2),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.map_pin,
                        size: 11.sp,
                        color: AppColors.greyColor,
                      ),
                      setWidth(width: 3),
                      Expanded(
                        child: Text(
                          address,
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 12,
                            color: AppColors.greyColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Mobile number pill
          if (mobile.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.blackColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.phone_fill,
                    size: 11.sp,
                    color: AppColors.blackColor,
                  ),
                  setWidth(width: 4),
                  Text(
                    mobile,
                    style: CustomTextStyle.customOpenSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
