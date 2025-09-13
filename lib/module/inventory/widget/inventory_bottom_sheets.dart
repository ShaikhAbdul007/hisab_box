import 'package:flutter/material.dart';
import 'package:inventory/common_widget/common_bottom_sheet.dart';
import 'package:inventory/common_widget/common_nodatafound.dart';
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
  required List<dynamic> listItems,

  required void Function() addInventoryOnTap,
  required dynamic Function(dynamic) notifyParent,
  required void Function() manuallyInventoryOnTap,
  required InventroyController controller,
}) {
  commonBottomSheet(
    label: 'Add Manual Product',
    onPressed: () {
      controller.clear();
      controller.cameraStart();
    },
    child:
        listItems.isEmpty
            ? CommonNodatafound(message: 'No loose product found')
            : ManuallyInventoryBottomsheetComponent(
              addInventoryOnTap: addInventoryOnTap,
              listItems: listItems,
              notifyParent: notifyParent,
              formkeys: formkeys,
              controller: controller,
              manuallyInventoryOnTap: manuallyInventoryOnTap,
            ),
  );
}
