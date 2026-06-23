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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: iconColor),
          setWidth(width: 10),
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
    return Container(
      margin: SymmetricPadding(horizontal: 12, vertical: 5).getPadding(),
      padding: SymmetricPadding(horizontal: 12, vertical: 10).getPadding(),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.deepPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              CupertinoIcons.money_dollar_circle_fill,
              color: AppColors.deepPurple,
              size: 22.sp,
            ),
          ),
          setWidth(width: 10),
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
                setHeight(height: 3),
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
                          borderRadius: BorderRadius.circular(4.r),
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
                      setWidth(width: 8),
                    ],
                    Icon(
                      CupertinoIcons.calendar,
                      size: 11.sp,
                      color: AppColors.greyColor,
                    ),
                    setWidth(width: 3),
                    Text(
                      formatDateTime(expense.createdAt ?? ''),
                      style: CustomTextStyle.customOpenSans(
                        fontSize: 11,
                        color: AppColors.greyColor,
                      ),
                    ),
                    setWidth(width: 6),
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
                // if (expense.name != null && expense.name!.isNotEmpty) ...[
                //   setHeight(height: 4),
                //   Text(
                //     expense.name!,
                //     style: CustomTextStyle.customOpenSans(
                //       fontSize: 11,
                //       color: AppColors.greyColor,
                //     ),
                //     maxLines: 2,
                //     overflow: TextOverflow.ellipsis,
                //   ),
                // ],
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
