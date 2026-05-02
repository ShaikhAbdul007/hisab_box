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
}
