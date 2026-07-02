import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/appbar_add_button.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_dropdown.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/capitalization_strings.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/set_format_date.dart';
import 'package:inventory/module/expense/model/all_expense_model.dart';
import 'package:inventory/responsive_layout/dimension.dart';
import '../../../common_widget/common_button.dart';
import '../../../helper/app_message.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/expense/controller/expense_controller.dart';
import '../../../keys/keys.dart';
import '../model/expens_model.dart';

class _SheetInfoBanner extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String message;
  const _SheetInfoBanner({
    required this.icon,
    required this.iconColor,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bool desktop = isDesktop(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(desktop ? 10 : 10.r),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: desktop ? 18 : 18.sp, color: iconColor),
          desktop ? const SizedBox(width: 10) : setWidth(width: 10),
          Expanded(
            child: Text(
              message,
              style: CustomTextStyle.customOpenSans(
                fontSize: 12,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final AllExpenseData expense;

  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    final bool desktop = isDesktop(context);
    return Container(
      margin:
          desktop
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 5)
              : SymmetricPadding(horizontal: 12, vertical: 5).getPadding(),
      padding:
          desktop
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
              : SymmetricPadding(horizontal: 12, vertical: 10).getPadding(),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(desktop ? 12 : 12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: desktop ? 44 : 44.w,
            height: desktop ? 44 : 44.h,
            decoration: BoxDecoration(
              color: AppColors.deepPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(desktop ? 10 : 10.r),
            ),
            child: Icon(
              CupertinoIcons.money_dollar_circle_fill,
              color: AppColors.deepPurple,
              size: desktop ? 22 : 22.sp,
            ),
          ),
          desktop ? const SizedBox(width: 10) : setWidth(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        expense.name ?? "",
                        style: CustomTextStyle.customPoppin(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '₹${expense.amount}',
                      style: CustomTextStyle.customPoppin(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
                desktop ? const SizedBox(height: 3) : setHeight(height: 3),
                Row(
                  children: [
                    if (expense.paymentMode != null &&
                        expense.paymentMode!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.deepPurple.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(
                            desktop ? 4 : 4.r,
                          ),
                        ),
                        child: Text(
                          expense.paymentMode.toCapitalized(),
                          style: CustomTextStyle.customOpenSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepPurple,
                          ),
                        ),
                      ),
                      desktop ? const SizedBox(width: 8) : setWidth(width: 8),
                    ],
                    Icon(
                      CupertinoIcons.calendar,
                      size: desktop ? 11 : 11.sp,
                      color: AppColors.greyColor,
                    ),
                    desktop ? const SizedBox(width: 3) : setWidth(width: 3),
                    Text(
                      formatDateTime(expense.createdAt ?? ''),
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                    desktop ? const SizedBox(width: 6) : setWidth(width: 6),
                    Text(
                      formatDateTime(
                        expense.createdAt ?? '',
                        showTime: true,
                        showDate: false,
                      ),
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Expense extends GetView<ExpenseController> {
  const Expense({super.key});

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            'Expense',
            style: CustomTextStyle.customNato(fontSize: 16),
          ),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Get.back(),
          ),
          surfaceTintColor: AppColors.greyColorShade100,
          backgroundColor: AppColors.greyColorShade100,
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left pane: list of expenses
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Obx(
                  () =>
                      controller.isExpenseLoading.value
                          ? Center(
                              child: CommonProgressBar(
                                color: AppColors.blackColor,
                                size: 30,
                              ),
                            )
                          : controller.expenseList.isNotEmpty
                          ? ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.expenseList.length,
                            itemBuilder: (context, index) {
                              var list = controller.expenseList[index];
                              return _ExpenseCard(expense: list);
                            },
                          )
                          : const CommonNoDataFound(
                            message: 'No expense found',
                          ),
                ),
              ),
            ),

            // Right pane: add expense form
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.only(top: 24, bottom: 24, right: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: expenseKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Record New Expense',
                        style: CustomTextStyle.customPoppin(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blackColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SheetInfoBanner(
                        icon: CupertinoIcons.money_dollar_circle_fill,
                        iconColor: AppColors.deepPurple,
                        message: 'Enter details for the new expense',
                      ),
                      const SizedBox(height: 20),
                      CommonTextField(
                        hintText: 'e.g. Rent, Electricity, Tea',
                        label: 'Expense Name',
                        controller: controller.expensionName,
                        validator: (val) {
                          if (val!.isEmpty) return emptyExpenseName;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CommonTextField(
                        hintText: 'e.g. 500',
                        label: 'Amount',
                        keyboardType: TextInputType.number,
                        inputLength: 10,
                        controller: controller.amount,
                        validator: (val) {
                          if (val!.isEmpty) return emptyExpenseAmount;
                          if (double.tryParse(val) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomStaticDropDown(
                        listItems: const ['Cash', 'UPI'],
                        hintText: 'Payment Mode',
                        notifyParent: (value) {
                          controller.selectedPaymentMode.value = value;
                        },
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => CommonButton(
                          isLoading: controller.isExpenseSaveLoading.value,
                          label: saveButton,
                          onTap: () async {
                            if (expenseKey.currentState!.validate()) {
                              var body = {
                                "name": controller.expensionName.text,
                                "amount": controller.amount.text,
                                "payment_mode":
                                    controller.selectedPaymentMode.value
                                        .toLowerCase(),
                              };
                              await controller.saveExpense(body);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return CommonAppbar(
      appBarLabel: 'Expense',
      firstActionChild: AppBarAddButton(
        tooltip: 'Add Expense',
        onTap: () {
          addNewExpense(keys: expenseKey);
        },
      ),
      body: Obx(
        () =>
            controller.isExpenseLoading.value
                ? CommonProgressBar(color: AppColors.blackColor, size: 30)
                : controller.expenseList.isNotEmpty
                ? ListView.builder(
                  itemCount: controller.expenseList.length,
                  itemBuilder: (context, index) {
                    var list = controller.expenseList[index];

                    return _ExpenseCard(expense: list);
                  },
                )
                : CommonNoDataFound(message: 'No expense found'),
      ),
    );
  }

  void addNewExpense({required GlobalKey<FormState> keys}) {
    commonBottomSheet(
      label: 'Add Expense',
      onPressed: () {
        Get.back();
        controller.clear();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Form(
          key: keys,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetInfoBanner(
                icon: CupertinoIcons.money_dollar_circle_fill,
                iconColor: AppColors.deepPurple,
                message: 'Enter details for the new expense',
              ),
              setHeight(height: 14),
              CommonTextField(
                hintText: 'e.g. Rent, Electricity, Tea',
                label: 'Expense Name',
                contentPadding: SymmetricPadding(horizontal: 10).getPadding(),
                controller: controller.expensionName,
                validator: (val) {
                  if (val!.isEmpty) return emptyExpenseName;
                  return null;
                },
              ),
              setHeight(height: 14),
              CommonTextField(
                hintText: 'e.g. 500',
                label: 'Amount',
                keyboardType: TextInputType.number,
                inputLength: 10,
                contentPadding: SymmetricPadding(horizontal: 10).getPadding(),
                controller: controller.amount,
                validator: (val) {
                  if (val!.isEmpty) {
                    return emptyExpenseAmount;
                  }
                  if (double.tryParse(val) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              setHeight(height: 14),
              CustomStaticDropDown(
                listItems: const ['Cash', 'UPI'],
                hintText: 'Payment Mode',
                //   selectedDropDownItem: controller.selectedPaymentMode.value,
                notifyParent: (value) {
                  controller.selectedPaymentMode.value = value;
                },
              ),
              // setHeight(height: 14),
              // CommonTextField(
              //   hintText: 'e.g. Office maintenance',
              //   label: 'Notes (Optional)',
              //   contentPadding: SymmetricPadding(horizontal: 10).getPadding(),
              //   controller: controller.notes,
              // ),
              setHeight(height: 20),
              Obx(
                () => CommonButton(
                  isLoading: controller.isExpenseSaveLoading.value,
                  label: saveButton,
                  onTap: () async {
                    if (keys.currentState!.validate()) {
                      var body = {
                        "name": controller.expensionName.text,
                        "amount": controller.amount.text,
                        "payment_mode":
                            controller.selectedPaymentMode.value.toLowerCase(),
                      };
                      await controller.saveExpense(body);
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
