import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Swipeable photos with dot indicators.
/// Shows a blue placeholder if an asset is missing, so the app never crashes.
class HostelImageCarousel extends StatefulWidget {
  const HostelImageCarousel({
    super.key,
    required this.images,
    this.height = 180,
    this.borderRadius = BorderRadius.zero,
  });

  final List<String> images;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<HostelImageCarousel> createState() => _HostelImageCarouselState();
}

class _HostelImageCarouselState extends State<HostelImageCarousel> {
  int _index = 0;

  Widget _placeholder() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFBFD3FF), Color(0xFF7FA6FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: const Center(
      child: Icon(Icons.apartment_rounded, size: 56, color: Colors.white),
    ),
  );

  /// Photos can be bundled assets or web URLs (e.g. from Firebase Storage).
  Widget _image(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder(),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (images.isEmpty)
              _placeholder()
            else
              PageView.builder(
                itemCount: images.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _image(images[i]),
              ),
            if (images.length > 1)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : Colors.white70,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
