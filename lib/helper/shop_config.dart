import 'package:inventory/helper/shop_type.dart';

class ShopConfig {
  final bool supportsLooseStock;
  final bool supportsGRStock;
  final String categoryLabel; // "Animal Category" / "Size Category"
  final String categoryEmptyMsg; // "No animal category found" / ...
  final String categoryHintText; // text field hint in bottom sheet
  final String categoryAddLabel; // bottom sheet title
  final String categoryValidationMsg; // empty validation error
  final String categoryAddSuccess; // snackbar on add
  final String categoryDeleteSuccess; // snackbar on delete
  final String looseStockGridLabel; // "Loose Stock" / "Good Return(GR)"
  final bool supportsColorModule; // Color module only for Clothing Shop

  const ShopConfig({
    required this.supportsLooseStock,
    required this.supportsGRStock,
    required this.categoryLabel,
    required this.categoryEmptyMsg,
    required this.categoryHintText,
    required this.categoryAddLabel,
    required this.categoryValidationMsg,
    required this.categoryAddSuccess,
    required this.categoryDeleteSuccess,
    required this.looseStockGridLabel,
    required this.supportsColorModule,
  });
}

/// Single source of truth
const Map<ShopType, ShopConfig> shopConfigs = {
  ShopType.petShop: ShopConfig(
    supportsLooseStock: true,
    supportsGRStock: false,
    categoryLabel: 'Animal Category',
    categoryEmptyMsg: 'No animal category found',
    categoryHintText: 'Enter animal category',
    categoryAddLabel: 'Add Animal Category',
    categoryValidationMsg: 'Please enter animal category',
    categoryAddSuccess: 'Animal category added successfully',
    categoryDeleteSuccess: 'Animal category deleted successfully',
    looseStockGridLabel: 'Loose Stock',
    supportsColorModule: false,
  ),
  ShopType.clothingShop: ShopConfig(
    supportsLooseStock: false,
    supportsGRStock: true,
    categoryLabel: 'Size Category',
    categoryEmptyMsg: 'No size category found',
    categoryHintText: 'Enter size category',
    categoryAddLabel: 'Add Size Category',
    categoryValidationMsg: 'Please enter size category',
    categoryAddSuccess: 'Size category added successfully',
    categoryDeleteSuccess: 'Size category deleted successfully',
    looseStockGridLabel: 'Good Return(GR)',
    supportsColorModule: true,
  ),
};

ShopConfig configFor(ShopType type) =>
    shopConfigs[type] ?? shopConfigs[ShopType.petShop]!;
