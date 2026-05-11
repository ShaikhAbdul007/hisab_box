import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/invoice_barcode_designer/model/barcode_layout_model.dart';
import 'package:inventory/module/invoice_barcode_designer/model/invoice_config_model.dart';
import 'package:inventory/module/invoice_barcode_designer/repo/designer_repo.dart';

class InvoiceDesignerController extends GetxController with CacheManager {
  final _repo = DesignerRepo();

  Rx<InvoiceConfigModel> invoiceConfig = Rx<InvoiceConfigModel>(
    const InvoiceConfigModel(),
  );
  RxBool isSaving = false.obs;
  RxBool isLoading = false.obs;
  RxList<InvoiceTemplate> availableTemplates = <InvoiceTemplate>[].obs;

  @override
  void onReady() {
    availableTemplates.value = InvoiceTemplate.all;
    loadInvoiceConfig();
    super.onReady();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadInvoiceConfig() async {
    isLoading.value = true;
    try {
      invoiceConfig.value = await _repo.getInvoiceConfig();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Template Selection ────────────────────────────────────────────────────

  /// Updates only [templateId]. All other fields remain unchanged.
  void selectTemplate(String templateId) {
    invoiceConfig.value = invoiceConfig.value.copyWith(templateId: templateId);
  }

  // ── Font Size ─────────────────────────────────────────────────────────────

  /// Updates only [fontSize]. All other fields remain unchanged.
  void setFontSize(FontSizeOption size) {
    invoiceConfig.value = invoiceConfig.value.copyWith(fontSize: size);
  }

  void setInvoiceFontFamily(DesignerFontFamily family) {
    invoiceConfig.value = invoiceConfig.value.copyWith(
      invoiceFontFamily: family,
    );
  }

  // ── Field Visibility ──────────────────────────────────────────────────────

  /// Toggles a single visibility field. Only the targeted field changes.
  /// [fieldKey] must be one of:
  /// showLogo, showGST, showAddress, showMobile,
  /// showBrand, showColor, showSize, showFlavour, showWeight, showAnimalType
  void toggleField(String fieldKey, bool value) {
    switch (fieldKey) {
      case 'showLogo':
        invoiceConfig.value = invoiceConfig.value.copyWith(showLogo: value);
        break;
      case 'showGST':
        invoiceConfig.value = invoiceConfig.value.copyWith(showGST: value);
        break;
      case 'showAddress':
        invoiceConfig.value = invoiceConfig.value.copyWith(showAddress: value);
        break;
      case 'showMobile':
        invoiceConfig.value = invoiceConfig.value.copyWith(showMobile: value);
        break;
      case 'showBrand':
        invoiceConfig.value = invoiceConfig.value.copyWith(showBrand: value);
        break;
      case 'showColor':
        invoiceConfig.value = invoiceConfig.value.copyWith(showColor: value);
        break;
      case 'showSize':
        invoiceConfig.value = invoiceConfig.value.copyWith(showSize: value);
        break;
      case 'showFlavour':
        invoiceConfig.value = invoiceConfig.value.copyWith(showFlavour: value);
        break;
      case 'showWeight':
        invoiceConfig.value = invoiceConfig.value.copyWith(showWeight: value);
        break;
      case 'showAnimalType':
        invoiceConfig.value = invoiceConfig.value.copyWith(
          showAnimalType: value,
        );
        break;
      default:
        break;
    }
  }

  // ── Footer Text ───────────────────────────────────────────────────────────

  /// Updates footer text. All other fields remain unchanged.
  void setFooterText(String text) {
    invoiceConfig.value = invoiceConfig.value.copyWith(footerText: text);
  }

  /// Updates terms & conditions text. All other fields remain unchanged.
  void setTermsAndConditionsText(String text) {
    invoiceConfig.value = invoiceConfig.value.copyWith(
      termsAndConditionsText: text,
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> saveInvoiceConfig() async {
    isSaving.value = true;
    try {
      final success = await _repo.saveInvoiceConfig(invoiceConfig.value);
      if (success) {
        showSnackBar(
          error: 'Invoice design saved successfully ✅',
          isError: false,
        );
      } else {
        showSnackBar(error: 'Failed to save design. Please try again.');
      }
    } catch (e) {
      showSnackBar(error: 'Error saving design: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  InvoiceTemplate get selectedTemplate =>
      InvoiceTemplate.byId(invoiceConfig.value.templateId);

  ShopType get currentShopType =>
      ShopType.fromString(retrieveUserDetail().data?.shopType ?? '');

  bool get isPetShop => currentShopType == ShopType.petShop;

  bool get isClothingShop => currentShopType == ShopType.clothingShop;
}
