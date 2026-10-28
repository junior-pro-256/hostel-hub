import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// HostelHub logo: white rounded tile with a gradient building icon.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (rect) => AppColors.brandGradient.createShader(rect),
          child: Icon(Icons.apartment_rounded,
              size: size * 0.58, color: Colors.white),
        ),
      ),
    );
  }
}
