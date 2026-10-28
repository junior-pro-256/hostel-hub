import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/filter_chip_item.dart';

/// Horizontally scrollable row of filter chips.
class HostelFilterBar extends StatelessWidget {
  const HostelFilterBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.sm),
        itemBuilder: (_, i) => FilterChipItem(
          label: filters[i],
          selected: filters[i] == selected,
          onTap: () => onSelected(filters[i]),
        ),
      ),
    );
  }
}
