import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_config.dart';
import 'core/constants/app_strings.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/hostel_provider.dart';
import 'providers/saved_hostels_provider.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/firestore_booking_repository.dart';
import 'repositories/firestore_hostel_repository.dart';
import 'repositories/firestore_saved_hostels_repository.dart';
import 'repositories/hostel_repository.dart';

/// Root widget: wires repositories -> providers, plus theme and routes.
/// Data providers reload whenever the signed-in user changes.
class HostelHubApp extends StatelessWidget {
  const HostelHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(FirebaseAuthRepository()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, HostelProvider>(
          create: (_) => HostelProvider(
            AppConfig.useMockHostels
                ? MockHostelRepository()
                : FirestoreHostelRepository(),
          ),
          update: (_, auth, hostels) {
            hostels!.onUserChanged(auth.user?.id);
            return hostels;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SavedHostelsProvider>(
          create: (ctx) {
            final auth = ctx.read<AuthProvider>();
            return SavedHostelsProvider(
              FirestoreSavedHostelsRepository(() => auth.user?.id),
            );
          },
          update: (_, auth, saved) {
            saved!.onUserChanged(auth.user?.id);
            return saved;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, BookingProvider>(
          create: (ctx) {
            final auth = ctx.read<AuthProvider>();
            return BookingProvider(
              FirestoreBookingRepository(() => auth.user?.id),
            );
          },
          update: (_, auth, bookings) {
            bookings!.onUserChanged(auth.user?.id);
            return bookings;
          },
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
