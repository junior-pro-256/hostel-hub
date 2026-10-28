import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/custom_search_bar.dart';

/// Search field + "List View" toggle shown over the map.
class MapSearchBar extends StatelessWidget {
  const MapSearchBar({
    super.key,
    required this.initialText,
    required this.onChanged,
    required this.onListView,
  });

  final String initialText;
  final ValueChanged<String> onChanged;
  final VoidCallback onListView;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomSearchBar(
            initialText: initialText,
            hint: 'Search this area',
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            onTap: onListView,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.view_list_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text('List',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
