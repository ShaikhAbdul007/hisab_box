import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_dropdown.dart';
import '../../../common_widget/common_button.dart';
import '../../../common_widget/common_popup_appbar.dart';
import '../../../common_widget/size.dart';
import '../../../common_widget/textfiled.dart';
import '../../../helper/app_message.dart';
import '../../../helper/helper.dart';
import '../../../keys/keys.dart';
import '../controller/inventory_controller.dart';

// class InventoryUpdatePopupComponent extends StatelessWidget {
//   final InventoryListController controller;
//   final int index;
//   const InventoryUpdatePopupComponent({
//     super.key,
//     required this.controller,
//     required this.index,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: formkeys,
//       child: Column(
//         children: [
//           CommonPopupAppbar(
//             label: 'Update Info',
//             onPressed: () {
//               Get.back();
//               controller.clear();
//             },
//           ),
//           Divider(),
//           Row(
//             children: [
//               Flexible(
//                 child: CommonTextField(
//                   label: 'Name',
//                   contentPadding: EdgeInsets.symmetric(
//                     vertical: 5,
//                     horizontal: 5,
//                   ),
//                   hintText: 'Enter product name',
//                   controller: controller.name,
//                   validator: (name) {
//                     if (name!.isEmpty) {
//                       return emptyProductName;
//                     } else {
//                       return null;
//                     }
//                   },
//                 ),
//               ),
//               Flexible(
//                 child: CommonTextField(
//                   label: 'Quantity',
//                   contentPadding: EdgeInsets.symmetric(
//                     vertical: 5,
//                     horizontal: 5,
//                   ),
//                   inputLength: 5,
//                   keyboardType: TextInputType.numberWithOptions(
//                     signed: false,
//                     decimal: false,
//                   ),
//                   hintText: 'Enter product quantity',
//                   controller: controller.updateQuantity,
//                   validator: (quantity) {
//                     if (quantity!.isEmpty) {
//                       return emptyProductQuantity;
//                     } else {
//                       return null;
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//           setHeight(height: 10),
//           Row(
//             children: [
//               Flexible(
//                 child: CommonTextField(
//                   label: 'Selling Price',
//                   inputLength: 5,
//                   keyboardType: TextInputType.numberWithOptions(
//                     signed: false,
//                     decimal: false,
//                   ),
//                   contentPadding: EdgeInsets.symmetric(
//                     vertical: 5,
//                     horizontal: 5,
//                   ),
//                   hintText: 'Selling Price (sp)',
//                   controller: controller.sellingPrice,
//                   validator: (sellingPrice) {
//                     if (sellingPrice!.isEmpty) {
//                       return emptyProductSellingPrice;
//                     } else {
//                       return null;
//                     }
//                   },
//                 ),
//               ),
//               Flexible(
//                 child: CommonTextField(
//                   label: 'Purchase Price',
//                   contentPadding: EdgeInsets.symmetric(
//                     vertical: 5,
//                     horizontal: 5,
//                   ),
//                   hintText: 'Purchase Price',
//                   controller: controller.purchasePrice,
//                   validator: (purchasePrice) {
//                     if (purchasePrice!.isEmpty) {
//                       return emptyProductPurchasePrice;
//                     } else {
//                       return null;
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//           setHeight(height: 10),
//           controller.isFlavorAndWeightNotRequired.value
//               ? Row(
//                 children: [
//                   Flexible(
//                     flex: 4,
//                     child: CommonTextField(
//                       label: 'Flavor',
//                       contentPadding: EdgeInsets.symmetric(
//                         vertical: 5,
//                         horizontal: 5,
//                       ),
//                       hintText: 'Flavor',
//                       controller: controller.flavor,
//                       validator: (flavor) {
//                         if (flavor!.isEmpty) {
//                           return emptyflavor;
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                   ),
//                   Flexible(
//                     flex: 2,
//                     child: CommonTextField(
//                       label: 'Weight',
//                       contentPadding: EdgeInsets.symmetric(
//                         vertical: 5,
//                         horizontal: 5,
//                       ),
//                       hintText: 'Weight',
//                       controller: controller.weight,
//                       validator: (weight) {
//                         if (weight!.isEmpty) {
//                           return emptyWeight;
//                         } else {
//                           return null;
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               )
//               : Container(),
//           setHeight(height: 10),
//           CustomDropDown(
//             selectedDropDownItem: controller.isLoose.value,
//             listItems: [true, false],
//             hintText: 'Select isLoose',
//             notifyParent: (val) {
//               controller.isLoose.value = val;
//             },
//           ),
//           setHeight(height: 10),
//           Obx(
//             () => CommonButton(
//               isLoading: controller.isSaveLoading.value,
//               label: saveButton,
//               onTap: () {
//                 if (formkeys.currentState!.validate()) {
//                   unfocus();
//                   controller.updateProductQuantity(
//                     barcode: controller.productList[index].barcode ?? '',
//                   );
//                 }
//               },
//             ),
//           ),
//           setHeight(height: 10),
//         ],
//       ),
//     );
//   }

  // void updateDataDialog({
  //   required bool add,
  //   required GlobalKey<FormState> formkeys,
  // }) {
  //   Get.defaultDialog(
  //     title: '',
  //     titleStyle: CustomTextStyle.customNato(fontSize: 0),
  //     titlePadding: EdgeInsets.zero,
  //     barrierDismissible: false,
  //     content: Form(
  //       key: formkeys,
  //       child: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             CommonPopupAppbar(
  //               label: add ? 'Add Qauntity' : 'Subtract Qauntity',
  //               onPressed: () {
  //                 Get.back();
  //                 controller.qtyClear();
  //               },
  //             ),
  //             Divider(),
  //             Flexible(
  //               child: CommonTextField(
  //                 label: 'Qauntity',
  //                 contentPadding: EdgeInsets.symmetric(
  //                   vertical: 5,
  //                   horizontal: 5,
  //                 ),
  //                 hintText: 'Qauntity',
  //                 controller: controller.addSubtractQty,
  //                 validator: (flavor) {
  //                   if (flavor!.isEmpty) {
  //                     return emptyflavor;
  //                   } else {
  //                     return null;
  //                   }
  //                 },
  //               ),
  //             ),
  //             setHeight(height: 10),
  //             Obx(
  //               () => CommonButton(
  //                 isLoading: controller.isSaveLoading.value,
  //                 label: saveButton,
  //                 onTap: () {
  //                   if (formkeys.currentState!.validate()) {
  //                     unfocus();
  //                     controller.updateProductQuantity(
  //                       barcode: controller.productList[index].barcode ?? '',
  //                       add: add,
  //                     );
  //                   }
  //                 },
  //               ),
  //             ),
  //             setHeight(height: 10),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
//}


// Column(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     CommonButton(
            //       height: 20,
            //       width: 40,
            //       bgColor: AppColors.greenColorShade100,
            //       label: '+',
            //       radius: 4,
            //       isbgReq: false,
            //       onTap: () {
            //         Get.back();
            //         updateDataDialog(add: true, formkeys: formkeys);
            //       },
            //     ),
            //     setHeight(height: 5),
            //     CommonButton(
            //       height: 20,
            //       width: 40,
            //       bgColor: AppColors.redColor,
            //       label: '-',
            //       isbgReq: false,
            //       radius: 4,
            //       onTap: () {
            //         Get.back();
            //         updateDataDialog(add: false, formkeys: formkeys);
            //       },
            //     ),
            //   ],
            // ),
            // setWidth(width: 15),