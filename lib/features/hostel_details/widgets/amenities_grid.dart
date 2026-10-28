import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/amenity_chip.dart';

/// Two-column grid of amenities.
class AmenitiesGrid extends StatelessWidget {
  const AmenitiesGrid({super.key, required this.amenities});

  final List<String> amenities;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimensions.sm,
      crossAxisSpacing: AppDimensions.sm,
      childAspectRatio: 3.4,
      children: amenities.map((a) => AmenityChip(label: a)).toList(),
    );
  }
}
