import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
import 'package:inventory/common_widget/common_progressbar.dart';
import '../controller/inventroy_controller.dart';
import '../widget/inventory_bottomsheet_component.dart';

openInventoryBottomSheet({
  required GlobalKey<FormState> formkeys,
  required InventroyController controller,
}) {
  commonBottomSheet(
    label: 'Product Info',
    onPressed: () {
      controller.clear();
      controller.cameraStart();
    },
    child: InventoryBottomsheetComponent(
      formkeys: formkeys,
      controller: controller,
    ),
  );
}

openLooseInventoryBottomSheet({
  required GlobalKey<FormState> formkeys,
  required InventroyController controller,
}) {
  commonBottomSheet(
    label: 'Loose Product Info',
    onPressed: () {
      controller.clear();
      controller.cameraStart();
    },
    child: LooseInventoryBottomsheetComponent(
      formkeys: formkeys,
      controller: controller,
    ),
  );
}

void openManuallySellBottomSheet({
  required GlobalKey<FormState> formkeys,
  required void Function() onPressedOnTap,
  required Widget child,
}) {
  commonBottomSheet(
    label: 'Add Manual Product',
    onPressed: onPressedOnTap,
    child: child,
  );
}
