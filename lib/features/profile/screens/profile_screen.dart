import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../models/booking.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/hostel_provider.dart';
import '../../../providers/saved_hostels_provider.dart';

/// Student profile, quick stats and booking history.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in any time.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign out')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<AuthProvider>().signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingProvider>().bookings.reversed.toList();
    final savedCount = context.watch<SavedHostelsProvider>().ids.length;
    final hostels = context.watch<HostelProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  foregroundImage: user?.photoUrl == null
                      ? null
                      : NetworkImage(user!.photoUrl!),
                  child: const Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.label ?? 'Student',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(user?.email ?? '',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text(user?.providerLabel ?? '',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(child: _Stat(label: 'Saved', value: savedCount)),
              const SizedBox(width: AppDimensions.sm),
              Expanded(child: _Stat(label: 'Requests', value: bookings.length)),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          Text('My bookings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.sm),
          if (bookings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
              child: Center(
                child: Text('No visit or booking requests yet.',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            )
          else
            ...bookings.map((b) {
              final hostel = hostels.byId(b.hostelId);
              final roomName = hostel?.roomTypes
                  .where((r) => r.id == b.roomTypeId)
                  .map((r) => r.name)
                  .firstOrNull;
              return _BookingTile(
                title: hostel?.name ?? 'Hostel',
                subtitle: '${b.typeLabel} • ${roomName ?? 'Room'} • ${b.dateLabel}',
                status: b.status,
                onCancel: b.status == BookingStatus.pending
                    ? () => context.read<BookingProvider>().cancel(b.id)
                    : null,
              );
            }),
          const SizedBox(height: AppDimensions.lg),
          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: (i) {
          if (i != 3) Navigator.pushReplacementNamed(context, AppRoutes.tabs[i]);
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text('$value',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({
    required this.title,
    required this.subtitle,
    required this.status,
    this.onCancel,
  });

  final String title;
  final String subtitle;
  final BookingStatus status;
  final VoidCallback? onCancel;

  Color get _color {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status.name.toUpperCase(),
                      style: TextStyle(
                          color: _color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          if (onCancel != null)
            TextButton(onPressed: onCancel, child: const Text('Cancel')),
        ],
      ),
    );
  }
}
