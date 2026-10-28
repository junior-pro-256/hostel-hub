import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shown instead of the app when Firebase has not been configured yet.
class SetupErrorScreen extends StatelessWidget {
  const SetupErrorScreen({super.key, required this.details});

  final String details;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.settings_suggest_outlined, size: 56),
                const SizedBox(height: 16),
                Text('Firebase is not set up yet',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text(
                    'Run `flutterfire configure` in the project folder, then restart the app. '
                    'See backend/README.md for the full steps.'),
                const SizedBox(height: 16),
                Text(details, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
