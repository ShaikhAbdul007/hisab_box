import 'package:get/get.dart';
import 'package:inventory/cache_manager/cache_manager.dart';
import 'package:inventory/helper/helper.dart';
import 'package:inventory/helper/shop_type.dart';
import 'package:inventory/module/invoice_barcode_designer/model/barcode_layout_model.dart';
import 'package:inventory/module/invoice_barcode_designer/repo/designer_repo.dart';

class BarcodeLabelDesignerController extends GetxController with CacheManager {
  final _repo = DesignerRepo();

  Rx<BarcodeLayoutModel> barcodeLayout = Rx<BarcodeLayoutModel>(
    BarcodeLayoutModel.defaultLayout(),
  );
  RxBool isSaving = false.obs;
  RxBool isLoading = false.obs;

  /// Currently selected element type (for ElementPropertiesPanel)
  RxnString selectedElementType = RxnString(null);

  @override
  void onReady() {
    loadLayout();
    super.onReady();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadLayout() async {
    isLoading.value = true;
    try {
      final stored = await _repo.getBarcodeLayout();
      final shopDefault = _shopTypeDefault();

      // If stored layout has fewer elements than shop-type default,
      // it means it was saved before new fields were added — use shop default
      if (stored.elements.length < shopDefault.elements.length) {
        barcodeLayout.value = shopDefault;
      } else {
        barcodeLayout.value = stored.copyWith(
          canvasSize: CanvasSize.mm58,
          canvasWidth: CanvasSize.mm58.widthMm,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns the shop-type specific default layout
  BarcodeLayoutModel _shopTypeDefault() {
    final user = retrieveUserDetail();
    final shopType = ShopType.fromString(user.data?.shopType ?? '');
    switch (shopType) {
      case ShopType.clothingShop:
        return BarcodeLayoutModel.clothingShopDefault();
      case ShopType.petShop:
        return BarcodeLayoutModel.petShopDefault();
    }
  }

  // ── Element Position ──────────────────────────────────────────────────────

  /// Updates [elementType] position, clamping to canvas bounds.
  /// Only the target element changes — all others remain identical.
  void updateElementPosition(String elementType, double x, double y) {
    final layout = barcodeLayout.value;
    final scaleFactor = _canvasWidthPx / layout.canvasWidth;

    final updatedElements =
        layout.elements.map((e) {
          if (e.type.name != elementType) return e;

          final elementWidthMm = (e.width ?? _defaultTextWidthMm(e));
          final elementHeightMm = (e.height ?? _defaultTextHeightMm(e));

          // Convert px position back to mm
          final newXMm = x / scaleFactor;
          final newYMm = y / scaleFactor;

          // Clamp to canvas bounds
          final clampedX = newXMm.clamp(
            0.0,
            (layout.canvasWidth - elementWidthMm).clamp(
              0.0,
              layout.canvasWidth,
            ),
          );
          final clampedY = newYMm.clamp(
            0.0,
            (layout.canvasHeight - elementHeightMm).clamp(
              0.0,
              layout.canvasHeight,
            ),
          );

          return e.copyWith(x: clampedX, y: clampedY);
        }).toList();

    barcodeLayout.value = layout.copyWith(elements: updatedElements);
  }

  // ── Font Size ─────────────────────────────────────────────────────────────

  /// Updates font size of [elementType] only. All other elements unchanged.
  void updateElementFontSize(String elementType, double fontSize) {
    final layout = barcodeLayout.value;
    final updatedElements =
        layout.elements.map((e) {
          if (e.type.name != elementType) return e;
          return e.copyWith(fontSize: fontSize);
        }).toList();
    barcodeLayout.value = layout.copyWith(elements: updatedElements);
  }

  // ── Visibility ────────────────────────────────────────────────────────────

  /// Toggles visibility of [elementType] only. All other elements unchanged.
  void updateElementVisibility(String elementType, bool visible) {
    final layout = barcodeLayout.value;
    final updatedElements =
        layout.elements.map((e) {
          if (e.type.name != elementType) return e;
          return e.copyWith(visible: visible);
        }).toList();
    barcodeLayout.value = layout.copyWith(elements: updatedElements);
  }

  // ── Canvas Size ───────────────────────────────────────────────────────────

  /// 58mm only — keeps canvas fixed to 58mm.
  void setCanvasSize(CanvasSize size) {
    barcodeLayout.value = barcodeLayout.value.copyWith(
      canvasSize: CanvasSize.mm58,
      canvasWidth: CanvasSize.mm58.widthMm,
    );
  }

  void setFixedPriceLabel(bool value) {
    barcodeLayout.value = barcodeLayout.value.copyWith(fixedPriceLabel: value);
  }

  void setTextFontFamily(DesignerFontFamily family) {
    barcodeLayout.value = barcodeLayout.value.copyWith(textFontFamily: family);
  }

  // ── Selection ─────────────────────────────────────────────────────────────

  void selectElement(String? elementType) {
    selectedElementType.value = elementType;
  }

  BarcodeElement? get selectedElement {
    final type = selectedElementType.value;
    if (type == null) return null;
    try {
      return barcodeLayout.value.elements.firstWhere(
        (e) => e.type.name == type,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> saveLayout() async {
    isSaving.value = true;
    try {
      final success = await _repo.saveBarcodeLayout(barcodeLayout.value);
      if (success) {
        showSnackBar(error: 'Layout saved successfully ✅', isError: false);
      } else {
        showSnackBar(error: 'Failed to save layout. Please try again.');
      }
    } catch (e) {
      showSnackBar(error: 'Error saving layout: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void resetToDefault() {
    barcodeLayout.value = _shopTypeDefault();
    selectedElementType.value = null;
  }

  // ── Canvas pixel width (for mm↔px conversion) ────────────────────────────

  /// Canvas display width in pixels (used for coordinate conversion).
  /// 58mm at 96dpi ≈ 219px; 80mm ≈ 302px
  double get _canvasWidthPx => barcodeLayout.value.canvasWidth * 96 / 25.4;

  double get canvasWidthPx => _canvasWidthPx;

  double get canvasHeightPx => barcodeLayout.value.canvasHeight * 96 / 25.4;

  // ── Helpers ───────────────────────────────────────────────────────────────

  double _defaultTextWidthMm(BarcodeElement e) {
    switch (e.type) {
      case ElementType.productName:
        return 30.0;
      case ElementType.price:
        return 15.0;
      case ElementType.weight:
      case ElementType.flavour:
      case ElementType.animalType:
      case ElementType.color:
      case ElementType.brand:
      case ElementType.category:
      case ElementType.expiry:
        return 20.0;
      default:
        return 10.0;
    }
  }

  double _defaultTextHeightMm(BarcodeElement e) => 5.0;
}
