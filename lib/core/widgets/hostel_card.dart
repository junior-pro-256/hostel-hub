import 'package:flutter/material.dart';

import '../../models/hostel.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'hostel_image_carousel.dart';
import 'price_tag.dart';
import 'rating_badge.dart';

/// Reusable hostel card: photo, favorite button, rating, price, room tags.
class HostelCard extends StatelessWidget {
  const HostelCard({
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
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                HostelImageCarousel(
                  images: hostel.images,
                  height: AppDimensions.cardImageHeight,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusLg)),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFavorite
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: RatingBadge(rating: hostel.rating),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
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
                      PriceTag(amount: hostel.startingPrice),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${hostel.address} • ${hostel.distanceLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: hostel.roomTypes
                        .map((r) => _RoomTag(
                            label: r.name, available: r.isAvailable))
                        .toList(),
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

/// Small room-type tag; greyed out when no rooms are left.
class _RoomTag extends StatelessWidget {
  const _RoomTag({required this.label, required this.available});

  final String label;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final color = available ? AppColors.primary : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
