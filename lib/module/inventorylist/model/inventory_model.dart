class InventoryModel {
  final String title;
  final String subtitle;
  final String intialLetter;
  final int stock;
  final int colorCode;

  InventoryModel({
    required this.intialLetter,
    required this.stock,
    required this.subtitle,
    required this.title,
    required this.colorCode
  });
}
