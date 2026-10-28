import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/hostel_card.dart';
import '../../../providers/hostel_provider.dart';
import '../../../providers/saved_hostels_provider.dart';

/// Scrollable list of hostel cards with loading / error / empty states.
class FeaturedHostelsSection extends StatelessWidget {
  const FeaturedHostelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HostelProvider>();
    final saved = context.watch<SavedHostelsProvider>();

    switch (provider.status) {
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadStatus.error:
        return _Message(
          icon: Icons.error_outline,
          text: AppStrings.somethingWrong,
          actionLabel: 'Retry',
          onAction: provider.load,
        );
      case LoadStatus.loaded:
        final hostels = provider.hostels;
        if (hostels.isEmpty) {
          return const _Message(
              icon: Icons.search_off, text: AppStrings.noResults);
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.md),
          itemCount: hostels.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.md),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Text(AppStrings.featured,
                  style: Theme.of(context).textTheme.titleLarge);
            }
            final h = hostels[i - 1];
            return HostelCard(
              hostel: h,
              isFavorite: saved.isSaved(h.id),
              onTap: () => Navigator.pushNamed(context, AppRoutes.detail,
                  arguments: h.id),
              onFavoriteTap: () => context.read<SavedHostelsProvider>().toggle(h.id),
            );
          },
        );
    }
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: AppDimensions.sm),
          Text(text, style: Theme.of(context).textTheme.titleMedium),
          if (actionLabel != null) ...[
            const SizedBox(height: AppDimensions.md),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
