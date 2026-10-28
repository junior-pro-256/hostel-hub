import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../models/hostel.dart';
import '../../../providers/hostel_provider.dart';
import '../../../providers/saved_hostels_provider.dart';
import '../widgets/google_hostel_map.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/mock_campus_map.dart';
import '../widgets/selected_hostel_card.dart';

/// Interactive map with price markers and a preview card.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HostelProvider>();
    final saved = context.watch<SavedHostelsProvider>();
    final hostels = provider.hostels;

    // Use the tapped hostel, or fall back to the first visible one.
    Hostel? selected;
    for (final h in hostels) {
      if (h.id == _selectedId) selected = h;
    }
    selected ??= hostels.isEmpty ? null : hostels.first;

    void select(String id) => setState(() => _selectedId = id);

    final Widget map = AppConfig.useGoogleMaps
        ? GoogleHostelMap(
            hostels: hostels, selectedId: selected?.id, onSelect: select)
        : MockCampusMap(
            hostels: hostels,
            selectedId: selected?.id,
            onSelect: select,
          );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: provider.status == LoadStatus.loaded
                ? map
                : const Center(child: CircularProgressIndicator()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: MapSearchBar(
                initialText: provider.query,
                onChanged: context.read<HostelProvider>().setQuery,
                onListView: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.home),
              ),
            ),
          ),
          if (provider.status == LoadStatus.loaded && hostels.isEmpty)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.md),
                  child: Text(AppStrings.noResults),
                ),
              ),
            ),
          if (selected != null)
            Positioned(
              left: AppDimensions.md,
              right: AppDimensions.md,
              bottom: AppDimensions.md,
              child: SelectedHostelCard(
                hostel: selected,
                isFavorite: saved.isSaved(selected.id),
                onTap: () => Navigator.pushNamed(context, AppRoutes.detail,
                    arguments: selected!.id),
                onFavoriteTap: () =>
                    context.read<SavedHostelsProvider>().toggle(selected!.id),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (i) {
          if (i != 1) Navigator.pushReplacementNamed(context, AppRoutes.tabs[i]);
        },
      ),
    );
  }
}
