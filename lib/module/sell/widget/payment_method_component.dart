// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:inventory/module/sell/widget/invoice_printer.dart';
// import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';

// import '../../../common_widget/colors.dart';
// import '../../../common_widget/common_button.dart';
// import '../../../common_widget/common_dialogue.dart';
// import '../../../common_widget/common_popup_appbar.dart';
// import '../../../common_widget/size.dart';
// import '../../../helper/textstyle.dart';

// class PaymentMethodComponent extends StatelessWidget {
//   const PaymentMethodComponent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return commonDialogBox(
//       context: context,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CommonPopupAppbar(
//             label: 'Payment Method',
//             onPressed: () {
//               Get.back();
//             },
//           ),
//           Divider(),
//           Text(
//             'Choose a payment method',
//             style: CustomTextStyle.customUbuntu(
//               fontSize: 15,
//               color: AppColors.greyColor,
//             ),
//           ),
//           setHeight(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               CommonButton(
//                 width: 120,
//                 label: 'Cash',
//                 onTap: () {
//                   Get.back();
//                 },
//               ),
//               CommonButton(
//                 width: 120,
//                 label: 'Online',
//                 onTap: () {
//                   Get.back();
//                   final upiDetails = UPIDetails(
//                     upiID: "8892359294@ybl",
//                     payeeName: "GoldenPets",
//                     amount: 100,
//                   );
//                   commonDialogBox(
//                     context: context,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         setHeight(height: 10),
//                         Text(
//                           'Scan Qr Code',
//                           style: CustomTextStyle.customPoppin(),
//                         ),
//                         setHeight(height: 20),
//                         UPIPaymentQRCode(
//                           upiDetails: upiDetails,
//                           size: 200,
//                           eyeStyle: const QrEyeStyle(
//                             eyeShape: QrEyeShape.square,
//                             color: AppColors.greyColor,
//                           ),
//                           embeddedImagePath: 'assets/goldenpets logo.png',
//                           embeddedImageSize: const Size(60, 60),
//                         ),
//                         setHeight(height: 30),
//                         CommonButton(
//                           label: 'Print',
//                           onTap: () {
//                             Get.back();
//                             commonDialogBox(
//                               context: context,
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   InvoicePrinterView(
//                                     onInitialized:
//                                         (p0) =>
//                                             controller.setReceiptController(p0),
//                                     scannedProductDetails:
//                                         controller.scannedProductDetails,
//                                   ),

//                                   Obx(
//                                     () => CommonButton(
//                                       isLoading:
//                                           controller.isPrintingLoading.value,
//                                       label: "Print Invoice",
//                                       onTap: () async {
//                                         if (controller
//                                                 .receiptController
//                                                 .value !=
//                                             null) {
//                                           await printReceipt(
//                                             controller.receiptController.value!,

//                                             context,
//                                           );
//                                         }
//                                       },
//                                     ),
//                                   ),
//                                   setHeight(height: 30),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                         setHeight(height: 20),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//           setHeight(height: 20),
//         ],
//       ),
//     );
//   }
// }
