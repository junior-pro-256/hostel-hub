import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';

/// Blue price badge, e.g. "UGX 1,200,000 / sem".
class PriceTag extends StatelessWidget {
  const PriceTag({super.key, required this.amount, this.compact = false});

  final int amount;
  final bool compact;

  /// 1200000 -> "1,200,000"
  static String format(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  /// 1200000 -> "1.2M" (used on map markers)
  static String short(int value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return '${m.toStringAsFixed(m == m.roundToDouble() ? 0 : 1)}M';
    }
    return '${(value / 1000).round()}K';
  }

  @override
  Widget build(BuildContext context) {
    final text = compact
        ? short(amount)
        : 'UGX ${format(amount)} ${AppStrings.perSemester}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
