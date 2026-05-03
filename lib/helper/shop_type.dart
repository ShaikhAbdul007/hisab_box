import 'package:inventory/helper/shop_config.dart';

enum ShopType {
  clothingShop,
  petShop;

  static ShopType fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'clothing shop':
        return ShopType.clothingShop;
      case 'pet shop':
      default:
        return ShopType.petShop;
    }
  }

  ShopConfig get config => configFor(this);
}
