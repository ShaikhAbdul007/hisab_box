import 'package:flutter/material.dart';
import 'package:inventory/common_widget/colors.dart';
import 'package:inventory/module/invoice_barcode_designer/model/barcode_layout_model.dart';

class DraggableCanvas extends StatelessWidget {
  final BarcodeLayoutModel layout;
  final Function(String elementType, double x, double y) onElementMoved;
  final Function(String elementType) onElementSelected;
  final String? selectedElementType;

  const DraggableCanvas({
    super.key,
    required this.layout,
    required this.onElementMoved,
    required this.onElementSelected,
    this.selectedElementType,
  });

  /// mm → px conversion (96 dpi)
  double _mmToPx(double mm) => mm * 96 / 25.4;

  double get _canvasWidthPx => _mmToPx(layout.canvasWidth);
  double get _canvasHeightPx => _mmToPx(layout.canvasHeight);

  String get _fontFamily {
    switch (layout.textFontFamily) {
      case DesignerFontFamily.montserrat:
        return 'Montserrat';
      case DesignerFontFamily.openSans:
        return 'Open Sans';
      case DesignerFontFamily.poppins:
        return 'Poppins';
      case DesignerFontFamily.arOneSans:
        return 'AR One Sans';
      case DesignerFontFamily.raleway:
        return 'Raleway';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: _canvasWidthPx,
        height: _canvasHeightPx,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: Border.all(color: Colors.grey.shade400, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children:
              layout.elements
                  .where((e) => e.visible)
                  .map((e) => _buildDraggableElement(e))
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildDraggableElement(BarcodeElement element) {
    final isSelected = selectedElementType == element.type.name;
    final xPx = _mmToPx(element.x);
    final yPx = _mmToPx(element.y);

    return Positioned(
      left: xPx,
      top: yPx,
      child: GestureDetector(
        onTap: () => onElementSelected(element.type.name),
        onPanUpdate: (details) {
          // New position in px
          final newXPx = xPx + details.delta.dx;
          final newYPx = yPx + details.delta.dy;
          onElementMoved(element.type.name, newXPx, newYPx);
        },
        child: Container(
          decoration:
              isSelected
                  ? BoxDecoration(
                    border: Border.all(color: AppColors.deepPurple, width: 1.5),
                    borderRadius: BorderRadius.circular(2),
                  )
                  : null,
          padding: const EdgeInsets.all(2),
          child: _buildElementContent(element),
        ),
      ),
    );
  }

  Widget _buildElementContent(BarcodeElement element) {
    switch (element.type) {
      case ElementType.barcode:
        return _BarcodePreview(
          widthPx: _mmToPx(element.width ?? 38),
          heightPx: _mmToPx(element.height ?? 15),
        );
      case ElementType.productName:
        return Text(
          'Product Name',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: element.fontSize ?? 8,
            color: AppColors.blackColor,
            fontWeight: FontWeight.w700,
          ),
        );
      case ElementType.price:
        return Text(
          layout.fixedPriceLabel ? 'Fixed Price Rs. 0.00' : 'Rs. 0.00',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: element.fontSize ?? 10,
            color: AppColors.blackColor,
            fontWeight: FontWeight.bold,
          ),
        );
      case ElementType.weight:
        return Text(
          '1 kg',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: element.fontSize ?? 7,
            color: AppColors.blackColor,
          ),
        );
      case ElementType.shopName:
        return Text(
          'Shop Name',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: element.fontSize ?? 10,
            color: AppColors.blackColor,
            fontWeight: FontWeight.bold,
          ),
        );
      case ElementType.flavour:
        return Text(
          'Chicken',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: element.fontSize ?? 7,
            color: AppColors.blackColor,
          ),
        );
      case ElementType.animalType:
        return Text(
          'Dog',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: element.fontSize ?? 7,
            color: AppColors.blackColor,
          ),
        );
      case ElementType.color:
        return Text(
          'Red',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: element.fontSize ?? 7,
            color: AppColors.blackColor,
          ),
        );
      case ElementType.brand:
        return Text(
          'Brand',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: element.fontSize ?? 7,
            color: AppColors.blackColor,
          ),
        );
      case ElementType.category:
        return Text(
          'Category',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: element.fontSize ?? 7,
            color: AppColors.blackColor,
          ),
        );
      case ElementType.expiry:
        return Text(
          'Exp: 12/26',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: element.fontSize ?? 7,
            color: AppColors.blackColor,
          ),
        );
    }
  }
}

/// Simple barcode preview placeholder (black bars)
class _BarcodePreview extends StatelessWidget {
  final double widthPx;
  final double heightPx;

  const _BarcodePreview({required this.widthPx, required this.heightPx});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthPx,
      height: heightPx,
      child: CustomPaint(painter: _BarcodePainter()),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    // Draw simple barcode-like stripes
    final barWidths = [2.0, 1.0, 3.0, 1.0, 2.0, 1.0, 2.0, 1.0, 3.0, 1.0, 2.0];
    double x = 0;
    bool isFilled = true;
    for (final w in barWidths) {
      if (isFilled) {
        canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      }
      x += w;
      isFilled = !isFilled;
      if (x >= size.width) break;
    }
    // Fill remaining with pattern
    while (x < size.width) {
      final w = (x + 2 < size.width) ? 2.0 : size.width - x;
      if (isFilled) {
        canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      }
      x += w;
      isFilled = !isFilled;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
