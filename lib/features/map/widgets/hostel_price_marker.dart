import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/price_tag.dart';

/// Blue price bubble with a pointer. Used on the mock map.
class HostelPriceMarker extends StatelessWidget {
  const HostelPriceMarker({
    super.key,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final int price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navy : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
                horizontal: selected ? 14 : 10, vertical: selected ? 8 : 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
              ],
            ),
            child: Text(
              PriceTag.short(price),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: selected ? 14 : 12,
              ),
            ),
          ),
          CustomPaint(size: const Size(12, 7), painter: _PointerPainter(color)),
        ],
      ),
    );
  }

  /// Draws the same bubble into an image for real Google Maps markers.
  static Future<BitmapDescriptor> toBitmap(int price,
      {required bool selected}) async {
    const ratio = 3.0;
    final tp = TextPainter(
      text: TextSpan(
        text: PriceTag.short(price),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: (selected ? 15 : 13) * ratio,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final padX = 12 * ratio, padY = 7 * ratio, pointer = 8 * ratio;
    final w = tp.width + padX * 2;
    final h = tp.height + padY * 2 + pointer;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = selected ? AppColors.navy : AppColors.primary;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h - pointer), Radius.circular(16 * ratio)),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w / 2 - pointer * 0.8, h - pointer)
        ..lineTo(w / 2 + pointer * 0.8, h - pointer)
        ..lineTo(w / 2, h)
        ..close(),
      paint,
    );
    tp.paint(canvas, Offset(padX, padY));

    final image = await recorder.endRecording().toImage(w.ceil(), h.ceil());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(data!.buffer.asUint8List(),
        imagePixelRatio: ratio);
  }
}

class _PointerPainter extends CustomPainter {
  _PointerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _PointerPainter old) => old.color != color;
}
