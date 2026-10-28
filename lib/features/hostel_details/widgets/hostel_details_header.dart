import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../models/hostel.dart';

/// Name, address, distance, rating and description.
class HostelDetailsHeader extends StatelessWidget {
  const HostelDetailsHeader({super.key, required this.hostel});

  final Hostel hostel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Text(hostel.name, style: textTheme.headlineSmall)),
            const SizedBox(width: AppDimensions.sm),
            RatingBadge(rating: hostel.rating, reviewCount: hostel.reviewCount),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text('${hostel.address} • ${hostel.distanceLabel}',
                  style: textTheme.bodySmall),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        Text(hostel.description, style: textTheme.bodyMedium),
      ],
    );
  }
}
