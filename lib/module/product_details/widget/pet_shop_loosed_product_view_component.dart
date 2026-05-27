import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:inventory/common_widget/common_button.dart';
import 'package:inventory/common_widget/common_padding.dart';
import 'package:inventory/common_widget/size.dart';
import 'package:inventory/helper/app_message.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/module/product_details/controller/controller.dart';
import 'package:inventory/module/product_details/widget/inventory_bottomsheep_component_text.dart';
import 'package:inventory/module/product_details/widget/product_field_card.dart';

class PetShopLoosedProductViewComponent extends StatelessWidget {
  final ProductController controller;
  final BuildContext context;
  final GlobalKey<FormState> formkeys;
  const PetShopLoosedProductViewComponent({
    super.key,
    required this.controller,
    required this.context,
    required this.formkeys,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkeys,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────
            // const ProductFormHeader(
            //   title: 'Add Loose Product',
            //   subtitle: 'Pet shop — loose stock entry',
            //   icon: CupertinoIcons.cube_box,
            // ),
            // ── Fields ──────────────────────────────────────────────────
            Padding(
              padding:
                  SymmetricPadding(horizontal: 14, vertical: 14).getPadding(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProductFieldCard(
                    icon: CupertinoIcons.barcode,
                    iconColor: const Color(0xFF1565C0),
                    title: 'Product Info',
                    child: InventoryBottomsheetComponentText(
                      readOnly1: true,
                      readOnly2: true,
                      controller1: controller.barcode,
                      controller2: controller.loooseProductName,
                      label1: 'Barcode',
                      hintText1: 'Enter barcode',
                      hintText2: 'Enter product name',
                      label2: 'Product name',
                      validator2: (name) {
                        if (name!.isEmpty) return emptyProductName;
                        return null;
                      },
                    ),
                  ),
                  setHeight(height: 12),
                  ProductFieldCard(
                    icon: CupertinoIcons.money_dollar_circle_fill,
                    iconColor: const Color(0xFF2E7D32),
                    title: 'Stock & Pricing',
                    child: InventoryBottomsheetComponentText(
                      inputLength1: 5,
                      keyboardType1: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: false,
                      ),
                      hintText1: 'Enter quantity',
                      label1: 'Quantity',
                      controller1: controller.looseQuantity,
                      validator1: (v) {
                        if (v!.isEmpty) return emptyProductPurchasePrice;
                        return null;
                      },
                      inputLength2: 5,
                      keyboardType2: TextInputType.numberWithOptions(
                        signed: false,
                        decimal: false,
                      ),
                      hintText2: 'Selling Price (sp)',
                      label2: 'Selling Price (₹)',
                      controller2: controller.looseSellingPrice,
                      validator2: (v) {
                        if (v!.isEmpty) return emptyProductSellingPrice;
                        return null;
                      },
                    ),
                  ),
                  setHeight(height: 20),
                  Obx(
                    () => CommonButton(
                      isLoading: controller.isLooseProductSave.value,
                      label: saveButton,
                      onTap: () async {
                        var body = {
                          "barcode": controller.scannedBarcodeValue.value,
                          "looseQtyToAdd": num.tryParse(
                            controller.looseQuantity.text,
                          ),
                          "sellingPrice": num.tryParse(
                            controller.looseSellingPrice.text,
                          ),
                          "reason": "Manual conversion",
                        };
                        if (formkeys.currentState!.validate()) {
                          unfocus();
                          controller.saveNewLooseProduct(body: body);
                        }
                      },
                    ),
                  ),
                  setHeight(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
