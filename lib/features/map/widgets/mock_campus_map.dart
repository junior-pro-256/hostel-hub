import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/hostel.dart';
import 'hostel_price_marker.dart';

/// Fallback map (no API key needed). Pan/zoom with fingers, tap markers.
/// Markers are spread to fit the hostels currently shown.
class MockCampusMap extends StatelessWidget {
  const MockCampusMap({
    super.key,
    required this.hostels,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Hostel> hostels;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  /// 0..1 position of [v] between [lo] and [hi] (centre if they are equal).
  double _norm(double v, double lo, double hi) =>
      (hi - lo) < 1e-6 ? 0.5 : (v - lo) / (hi - lo);

  @override
  Widget build(BuildContext context) {
    if (hostels.isEmpty) return Container(color: const Color(0xFFE6EEFF));

    final lats = hostels.map((h) => h.latitude);
    final lngs = hostels.map((h) => h.longitude);
    final minLat = lats.reduce(math.min), maxLat = lats.reduce(math.max);
    final minLng = lngs.reduce(math.min), maxLng = lngs.reduce(math.max);

    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth, h = box.maxHeight;
        return InteractiveViewer(
          minScale: 0.8,
          maxScale: 3,
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _MapBackgroundPainter()),
                ),
                for (final hostel in hostels)
                  Builder(builder: (_) {
                    // North is up; keep markers between search bar and card.
                    final nx = _norm(hostel.longitude, minLng, maxLng);
                    final ny = 1 - _norm(hostel.latitude, minLat, maxLat);
                    final x = w * (0.15 + nx * 0.7);
                    final y = h * (0.25 + ny * 0.35);
                    return Positioned(
                      left: x - 32,
                      top: y - 40,
                      child: HostelPriceMarker(
                        price: hostel.startingPrice,
                        selected: hostel.id == selectedId,
                        onTap: () => onSelect(hostel.id),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Simple "streets and parks" background.
class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEAF0FB));

    // A park block and a campus block.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.05, size.height * 0.1, size.width * 0.3,
              size.height * 0.2),
          const Radius.circular(16)),
      Paint()..color = const Color(0xFFD5E8D4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.55, size.height * 0.5, size.width * 0.38,
              size.height * 0.2),
          const Radius.circular(16)),
      Paint()..color = const Color(0xFFD6E0F5),
    );

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    for (double x = size.width * 0.1; x < size.width; x += size.width * 0.3) {
      canvas.drawLine(Offset(x, 0), Offset(x + 30, size.height), road);
    }
    for (double y = size.height * 0.15; y < size.height; y += size.height * 0.22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 24), road);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
