import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../providers/hostel_provider.dart';
import '../widgets/featured_hostels_section.dart';
import '../widgets/institution_picker_sheet.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/hostel_filter_bar.dart';

/// Home feed: search, filters and featured hostel cards.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HostelProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HomeAppBar(
              location: provider.institutionLabel,
              onLocationTap: () => showInstitutionPicker(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md, vertical: AppDimensions.sm),
              child: CustomSearchBar(
                initialText: provider.query,
                onChanged: context.read<HostelProvider>().setQuery,
              ),
            ),
            HostelFilterBar(
              filters: AppStrings.filters,
              selected: provider.filter,
              onSelected: context.read<HostelProvider>().setFilter,
            ),
            const SizedBox(height: AppDimensions.xs),
            const Expanded(child: FeaturedHostelsSection()),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (i) {
          if (i != 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.tabs[i]);
          }
        },
      ),
    );
  }
}
