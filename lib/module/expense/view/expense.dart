import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_appbar.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_dialogue.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/common_widget/textfiled.dart';
import 'package:inventory/helper/set_format_date.dart';
import '../../../helper/app_message.dart';
import 'package:inventory/helper/textstyle.dart';
import 'package:inventory/module/expense/controller/expense_controller.dart';
import '../../../keys/keys.dart';
import '../model/expens_model.dart';
import '../widget/add_expenses_button.dart';
import '../widget/expension_text.dart';

class Expense extends GetView<ExpenseController> {
  const Expense({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppbar(
      appBarLabel: 'Expense',
      firstActionChild: AddExpensesButton(
        onTap: () {
          addExpensesButtonOnTap(context, expenseKey);
        },
      ),
      body: Obx(
        () =>
            controller.isExpenseLoading.value
                ? CommonProgressbar(color: AppColors.blackColor)
                : controller.expenseList.isNotEmpty
                ? ListView.builder(
                  itemCount: controller.expenseList.length,
                  itemBuilder: (context, index) {
                    return ExpensText(
                      expensModel: controller.expenseList[index],
                    );
                  },
                )
                : CommonNodatafound(message: 'No expense found'),
      ),
    );
  }

  void addExpensesButtonOnTap(
    BuildContext context,
    GlobalKey<FormState> expenseKey,
  ) {
    commonDialogBox(
      context: context,
      child: CustomPadding(
        paddingOption: AllPadding(all: 16.0),
        child: Form(
          key: expenseKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPadding(
                paddingOption: SymmetricPadding(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expense Info',
                      style: CustomTextStyle.customRaleway(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                        controller.clear();
                      },
                      child: Icon(CupertinoIcons.xmark),
                    ),
                  ],
                ),
              ),
              setHeight(height: 20),
              SizedBox(
                height: 50,
                child: CommonTextField(
                  contentPadding: OnlyPadding(bottom: 5, left: 10).getPadding(),
                  hintText: 'Name',
                  label: 'Name',
                  controller: controller.expensionName,
                  validator: (name) {
                    if (name!.isEmpty) {
                      return emptyExpenseName;
                    }
                    return null;
                  },
                ),
              ),
              setHeight(height: 10),
              SizedBox(
                height: 50,
                child: CommonTextField(
                  contentPadding: OnlyPadding(bottom: 5, left: 10).getPadding(),
                  hintText: 'Amount',
                  label: 'Amount',
                  keyboardType: TextInputType.number,
                  inputLength: 4,
                  controller: controller.amount,
                  validator: (amount) {
                    if (amount!.isEmpty) {
                      return emptyExpenseAmount;
                    }
                    return null;
                  },
                ),
              ),
              setHeight(height: 10),
              SizedBox(
                height: 50,
                child: CommonTextField(
                  contentPadding: OnlyPadding(bottom: 5, left: 10).getPadding(),
                  hintText: 'Notes',
                  label: 'Notes',
                  controller: controller.notes,
                ),
              ),
              setHeight(height: 10),
              Obx(
                () => CommonButton(
                  isLoading: controller.isExpenseSaveLoading.value,
                  label: saveButton,
                  onTap: () async {
                    if (expenseKey.currentState!.validate()) {
                      String formattedTime = setFormateDate('h:mm a');
                      String formatDate = setFormateDate();
                      double amount = double.parse(controller.amount.text);
                      var expense = ExpenseModel(
                        amount: amount,
                        expenseName: controller.expensionName.text,
                        date: formatDate,
                        notes: controller.notes.text,
                        time: formattedTime,
                      );
                      await controller.saveExpense(expense);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
