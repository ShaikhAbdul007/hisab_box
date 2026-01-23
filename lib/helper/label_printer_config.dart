/// 🔥 LABEL PRINTER CONFIGURATION
/// Optimized settings for 25mm x 50mm label stickers
/// Prevents blank space between labels
library;

class LabelPrinterConfig {
  // 🔥 LABEL DIMENSIONS (in pixels at 203 DPI)
  static const double labelWidth = 189.0; // 50mm ≈ 189px
  static const double labelHeight = 95.0; // 25mm ≈ 95px

  // 🔥 BARCODE SETTINGS (optimized for centered layout)
  static const double barcodeHeight = 25.0; // Smaller for more text space
  static const double barcodeWidth = 175.0; // Centered width

  // 🔥 FONT SIZES (optimized for maximum visibility on small labels)
  static const double shopNameSize = 18.0; // Maximum visibility
  static const double productNameSize = 16.0; // Large and clear
  static const double detailsSize = 14.0; // Clear and readable
  static const double barcodeTextSize = 13.0; // Readable

  // 🔥 SPACING (minimal to avoid blank space)
  static const double topPadding = 2.0;
  static const double bottomPadding = 0.0; // ZERO to prevent blank space
  static const double sidePadding = 4.0;
  static const double elementSpacing = 1.0;

  // 🔥 PRINTER COMMANDS (ESC/POS commands for thermal printers)

  /// Reset printer formatting
  static List<int> get resetCommand => [0x1B, 0x40];

  /// Set label mode (for label printers)
  static List<int> get labelModeCommand => [0x1B, 0x69, 0x61, 0x01];

  /// Minimal line feed (reduces blank space)
  static List<int> get minimalFeedCommand => [0x0A];

  /// Full cut command
  static List<int> get fullCutCommand => [0x1D, 0x56, 0x00];

  /// Partial cut command (recommended for labels)
  static List<int> get partialCutCommand => [0x1D, 0x56, 0x01];

  /// Set line spacing to minimum
  static List<int> get minLineSpacingCommand => [0x1B, 0x33, 0x00];

  /// Set character spacing to minimum
  static List<int> get minCharSpacingCommand => [0x1B, 0x20, 0x00];

  // 🔥 LABEL PRINTER SPECIFIC COMMANDS

  /// Set label size (width, height in dots)
  static List<int> labelSizeCommand(int width, int height) {
    return [
      0x1B, 0x51, // Set label size command
      width & 0xFF, (width >> 8) & 0xFF, // Width (low byte, high byte)
      height & 0xFF, (height >> 8) & 0xFF, // Height (low byte, high byte)
    ];
  }

  /// Set print speed (1-5, where 1 is fastest)
  static List<int> printSpeedCommand(int speed) {
    return [0x1B, 0x53, speed.clamp(1, 5)];
  }

  /// Set print density (1-15, where 15 is darkest)
  static List<int> printDensityCommand(int density) {
    return [0x1B, 0x44, density.clamp(1, 15)];
  }

  // 🔥 HELPER METHODS

  /// Get optimized settings for 25mm x 50mm labels
  static Map<String, dynamic> get optimizedSettings => {
    'width': labelWidth,
    'height': labelHeight,
    'barcodeHeight': barcodeHeight,
    'barcodeWidth': barcodeWidth,
    'shopNameSize': shopNameSize,
    'productNameSize': productNameSize,
    'detailsSize': detailsSize,
    'barcodeTextSize': barcodeTextSize,
    'topPadding': topPadding,
    'bottomPadding': bottomPadding,
    'sidePadding': sidePadding,
    'elementSpacing': elementSpacing,
  };

  /// Get printer initialization commands
  static List<List<int>> get initCommands => [
    resetCommand,
    labelModeCommand,
    minLineSpacingCommand,
    minCharSpacingCommand,
    labelSizeCommand(189, 95), // 50mm x 25mm in dots
    printSpeedCommand(3), // Medium speed
    printDensityCommand(10), // Medium density
  ];

  /// Get post-print commands (to prevent blank space)
  static List<List<int>> get postPrintCommands => [
    minimalFeedCommand,
    // partialCutCommand, // Uncomment if your printer supports cutting
  ];
}
