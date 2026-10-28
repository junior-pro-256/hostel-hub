import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/hostel_card.dart';
import '../../../providers/hostel_provider.dart';
import '../../../providers/saved_hostels_provider.dart';

/// Hostels the student has favorited.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HostelProvider>();
    final saved = context.watch<SavedHostelsProvider>();
    final hostels =
        provider.allHostels.where((h) => saved.isSaved(h.id)).toList();

    Widget body;
    if (provider.status == LoadStatus.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (provider.status == LoadStatus.error) {
      body = Center(
        child: OutlinedButton(
            onPressed: provider.load, child: const Text('Retry')),
      );
    } else if (hostels.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: AppDimensions.sm),
            Text('No saved hostels yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Tap the heart on a hostel to save it.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.md),
        itemCount: hostels.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.md),
        itemBuilder: (context, i) {
          final h = hostels[i];
          return HostelCard(
            hostel: h,
            isFavorite: true,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.detail, arguments: h.id),
            onFavoriteTap: () =>
                context.read<SavedHostelsProvider>().toggle(h.id),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved (${hostels.length})'),
        automaticallyImplyLeading: false,
      ),
      body: body,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: (i) {
          if (i != 2) Navigator.pushReplacementNamed(context, AppRoutes.tabs[i]);
        },
      ),
    );
  }
}
