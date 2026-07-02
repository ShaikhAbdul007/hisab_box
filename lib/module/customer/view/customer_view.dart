import 'package:inventory/responsive_layout/dimension.dart';
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
    if (isDesktop(context)) {
      final desktopFormKey = GlobalKey<FormState>();
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Customer Directory'),
          surfaceTintColor: AppColors.greyColorShade100,
          backgroundColor: AppColors.greyColorShade100,
          actions: [
            Obx(() {
              if (controller.selectedCustomer.value != null) {
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.selectedCustomer.value = null;
                      controller.clear();
                    },
                    icon: const Icon(CupertinoIcons.add_circled, size: 16),
                    label: const Text('Add Customer Form'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blackColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left pane: Customers list & Search
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Search bar
                    CommonSearch(
                      icon: Obx(
                        () => controller.searchText.value.isNotEmpty
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
                      label: 'Search Directory',
                      hintText: 'Search by customer name or phone...',
                      controller: controller.searchController,
                      onChanged: (val) => controller.searchProduct(val),
                    ),
                    const SizedBox(height: 20),

                    // Customer database list
                    Expanded(
                      child: Obx(() {
                        if (controller.customDataLoading.value) {
                          return const Center(
                            child: CommonProgressBar(color: AppColors.blackColor),
                          );
                        }
                        if (controller.customerList.isEmpty) {
                          return const Center(
                            child: CommonNoDataFound(message: 'No customers found'),
                          );
                        }

                        final filtered = controller.customerList.where((item) {
                          final query = controller.searchText.value.toLowerCase();
                          return (item.name ?? '').toLowerCase().contains(query) ||
                              (item.mobileNo ?? '').toLowerCase().contains(query);
                        }).toList();

                        if (filtered.isEmpty) {
                          return Center(
                            child: CommonNoDataFound(message: 'No results for "${controller.searchText.value}"'),
                          );
                        }

                        return ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final customerData = filtered[index];
                            return Obx(() {
                              final isSelected = controller.selectedCustomer.value?.id == customerData.id;
                              return Container(
                                decoration: BoxDecoration(
                                  border: isSelected
                                      ? Border.all(color: AppColors.deepPurple, width: 1.5)
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _CustomerCard(
                                  description: customerData.description ?? '',
                                  name: customerData.name ?? '',
                                  mobile: customerData.mobileNo ?? '',
                                  address: customerData.address ?? '',
                                  onTap: () {
                                    controller.selectedCustomer.value = customerData;
                                    controller.setDataAsPerOptionSelected(customerData);
                                  },
                                ),
                              );
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Right pane: Form / Profile detail view
            Container(
              width: 420,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(left: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Obx(() {
                final customer = controller.selectedCustomer.value;
                
                // If no customer is selected, show "Create New Customer" form!
                if (customer == null) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Form(
                        key: desktopFormKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add New Customer',
                              style: CustomTextStyle.customPoppin(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blackColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Mobile lookup
                            CustomerViewDetailsMobileAutoCompleteWidget(controller: controller),
                            const SizedBox(height: 16),
                            
                            CommonTextField(
                              hintText: 'Full name',
                              label: 'Name',
                              controller: controller.nameController,
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Enter name';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            CommonTextField(
                              astraIsRequred: false,
                              hintText: 'Street, City',
                              label: 'Address',
                              controller: controller.addressController,
                            ),
                            const SizedBox(height: 16),
                            
                            CommonTextField(
                              astraIsRequred: false,
                              hintText: 'Optional note',
                              label: 'Description/Notes',
                              controller: controller.descriptionController,
                            ),
                            const SizedBox(height: 30),
                            
                            Obx(() => CommonButton(
                              isLoading: controller.isAddCustomerLoading.value,
                              label: 'Save Customer',
                              bgColor: controller.isCustomerFetchingByMobileNumberLoading.value
                                  ? AppColors.greyColor
                                  : AppColors.blackColor,
                              onTap: controller.isCustomerFetchingByMobileNumberLoading.value
                                  ? () {}
                                  : () async {
                                      if (desktopFormKey.currentState!.validate()) {
                                        final body = {
                                          'mobile_no': controller.mobileController.text.trim(),
                                          'name': controller.nameController.text.trim(),
                                          'address': controller.addressController.text.trim(),
                                          'description': controller.descriptionController.text.trim(),
                                        };
                                        controller.isAddCustomerLoading.value = true;
                                        try {
                                          final response = await controller.customerRepo.addCustomer(body: body);
                                          if (response.success == success) {
                                            showMessage(message: 'Customer saved successfully!');
                                            controller.clear();
                                            controller.fetchAllCustomers();
                                          } else {
                                            showSnackBar(error: response.msg ?? 'Failed to add customer.');
                                          }
                                        } catch (e) {
                                          showSnackBar(error: e.toString());
                                        } finally {
                                          controller.isAddCustomerLoading.value = false;
                                        }
                                      }
                                    },
                            )),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // If customer is selected, show profile details
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Customer Profile',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.greyColor),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.clear_circled_solid, color: Colors.grey),
                            onPressed: () {
                              controller.selectedCustomer.value = null;
                              controller.clear();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Avatar overview card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.blackColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white24,
                              radius: 28,
                              child: Text(
                                customer.name != null && customer.name!.isNotEmpty
                                    ? customer.name![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name ?? 'No Name',
                                    style: CustomTextStyle.customPoppin(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    customer.mobileNo ?? 'No Mobile',
                                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      const Text('Contact Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text(
                        (customer.address ?? '').isNotEmpty ? customer.address! : 'No address provided',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text('Notes / Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text(
                        (customer.description ?? '').isNotEmpty ? customer.description! : 'No description logs.',
                        style: const TextStyle(fontSize: 14),
                      ),
                      
                      const Spacer(),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showMessage(message: 'Customer profile details verified!');
                          },
                          icon: const Icon(CupertinoIcons.check_mark_circled),
                          label: const Text('Verified Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade50,
                            foregroundColor: Colors.green.shade800,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      );
    }

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
                                        description:
                                            customerData.description ?? '',
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
          key: controller.customerFormKey,
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
                            if (controller.customerFormKey.currentState!.validate()) {
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
  final String description;
  final VoidCallback? onTap;

  const _CustomerCard({
    required this.name,
    required this.description,
    required this.mobile,
    required this.address,
    this.onTap,
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
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
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (description.isNotEmpty) ...[
                    setHeight(height: 2),
                    Text(
                      description,
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 12,
                        color: AppColors.greyColor,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
