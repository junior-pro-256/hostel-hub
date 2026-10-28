import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2563FF);
  static const Color navy = Color(0xFF0B1B4D);
  static const Color background = Color(0xFFF6F8FC);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE3E8F2);
  static const Color textPrimary = navy;
  static const Color textSecondary = Color(0xFF6B7590);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color star = Color(0xFFFFB400);

  /// Splash / login background.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B1B4D),
      Color(0xFF1D4ED8),
      Color(0xFF2563FF),
      Color(0xFF60A5FA),
    ],
    stops: [0.0, 0.45, 0.75, 1.0],
  );
}
