import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../models/manager.dart';

/// Manager info with verified badge and Call / WhatsApp buttons.
/// A button is disabled when its callback is null (invalid contact).
class ManagerCard extends StatelessWidget {
  const ManagerCard({
    super.key,
    required this.manager,
    this.onCall,
    this.onWhatsApp,
  });

  final Manager manager;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;

  Widget _avatar() {
    const fallback = CircleAvatar(
      radius: 26,
      backgroundColor: Color(0xFFE6EEFF),
      child: Icon(Icons.person, color: AppColors.primary),
    );
    if (manager.photoAsset == null) return fallback;
    return ClipOval(
      child: Image.asset(
        manager.photoAsset!,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }

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
          Row(
            children: [
              _avatar(),
              const SizedBox(width: AppDimensions.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manager.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          manager.isVerified
                              ? Icons.verified
                              : Icons.info_outline,
                          size: 14,
                          color: manager.isVerified
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          manager.isVerified
                              ? 'Verified manager'
                              : 'Not yet verified',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onWhatsApp,
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
