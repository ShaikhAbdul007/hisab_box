import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/module/sell/controller/sell_list_after_scan_controller.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_dropdown.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';

class LooseSellBottomsheetComponent extends StatelessWidget {
  final GlobalKey<FormState> formkeys;
  final SellListAfterScanController controller;
  const LooseSellBottomsheetComponent({
    super.key,
    required this.formkeys,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkeys,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Flexible(
            child: CommonTextField(
              validator: (quantity) {
                if (quantity!.isEmpty) {
                  return emptyProductQuantity;
                } else {
                  return null;
                }
              },
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              inputLength: 5,
              keyboardType: TextInputType.numberWithOptions(),
              hintText: 'Enter quantity',
              label: 'Quantity',
              controller: controller.quantity,
            ),
          ),

          Row(
            children: [
              Flexible(
                flex: 2,
                child: CommonDropDown(
                  errorText: 'Please select',
                  listItems: controller.looseCategoryModelList,
                  hintText: 'Select Item',
                  notifyParent: (v) {
                    var list = controller.looseCategoryModelList;
                    for (int i = 0; i < list.length; i++) {
                      if (v == list[i].id) {
                        controller.name.text = list[i].name;
                        controller.id = v;
                        int amot =
                            list[i].price * int.parse(controller.quantity.text);
                        controller.amount.text = amot.toString();
                        print(v);
                      }
                    }
                  },
                ),
              ),
              Flexible(
                child: CommonTextField(
                  readOnly: true,
                  validator: (quantity) {
                    if (quantity!.isEmpty) {
                      return emptyProductQuantity;
                    } else {
                      return null;
                    }
                  },
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 5,
                  ),
                  inputLength: 5,
                  keyboardType: TextInputType.numberWithOptions(),
                  hintText: 'Amount',
                  label: 'Amount',
                  controller: controller.amount,
                ),
              ),
            ],
          ),

          Obx(
            () => CommonButton(
              isLoading: controller.isSaveLoading.value,
              label: 'Add',
              onTap: () async {
                if (formkeys.currentState!.validate()) {
                  unfocus();
                }
              },
            ),
          ),
          setHeight(height: 50),
        ],
      ),
    );
  }
}
