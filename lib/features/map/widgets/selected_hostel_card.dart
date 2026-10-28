import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/hostel_image_carousel.dart';
import '../../../core/widgets/price_tag.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../models/hostel.dart';

/// Compact preview of the hostel picked on the map.
class SelectedHostelCard extends StatelessWidget {
  const SelectedHostelCard({
    super.key,
    required this.hostel,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final Hostel hostel;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: HostelImageCarousel(
                images: hostel.images.take(1).toList(),
                height: 96,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            const SizedBox(width: AppDimensions.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(hostel.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium),
                      ),
                      GestureDetector(
                        onTap: onFavoriteTap,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isFavorite
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(hostel.distanceLabel,
                      style: textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBadge(rating: hostel.rating),
                      const Spacer(),
                      PriceTag(amount: hostel.startingPrice),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
