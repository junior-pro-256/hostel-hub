import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/price_tag.dart';
import '../../../models/room_type.dart';

/// Selectable room options. Rooms with no units left cannot be chosen.
class RoomSelector extends StatelessWidget {
  const RoomSelector({
    super.key,
    required this.rooms,
    required this.selectedId,
    required this.onSelected,
  });

  final List<RoomType> rooms;
  final String? selectedId;
  final ValueChanged<RoomType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rooms.map((room) {
        final selected = room.id == selectedId;
        final available = room.isAvailable;
        final statusColor = !available
            ? AppColors.error
            : room.availableUnits <= 2
            ? AppColors.warning
            : AppColors.success;
        final statusText = available
            ? '${room.availableUnits} left'
            : 'Fully booked';

        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.sm),
          child: Opacity(
            opacity: available ? 1 : 0.55,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              onTap: available ? () => onSelected(room) : null,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.sm + 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: statusColor),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '$statusText • sleeps ${room.capacity}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    PriceTag(amount: room.pricePerSemester),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
