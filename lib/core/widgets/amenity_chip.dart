import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Icon + label for one amenity.
class AmenityChip extends StatelessWidget {
  const AmenityChip({super.key, required this.label});

  final String label;

  static IconData iconFor(String label) {
    switch (label.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'security':
        return Icons.shield_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'study room':
        return Icons.menu_book_outlined;
      case 'laundry':
        return Icons.local_laundry_service_outlined;
      case 'power backup':
        return Icons.bolt;
      case 'canteen':
        return Icons.restaurant_outlined;
      case 'parking':
        return Icons.local_parking;
      case 'gym':
        return Icons.fitness_center;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconFor(label), size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
