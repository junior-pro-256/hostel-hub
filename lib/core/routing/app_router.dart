import 'package:flutter/material.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/bookings/screens/booking_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/hostel_details/screens/hostel_detail_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/saved/screens/saved_screen.dart';
import '../../models/booking.dart';

/// Route name constants.
class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const map = '/map';
  static const saved = '/saved';
  static const profile = '/profile';
  static const detail = '/hostel'; // argument: String hostelId
  static const booking = '/booking'; // argument: BookingArgs

  static const tabs = [home, map, saved, profile];
  static const _fade = [splash, login];
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page;
    switch (settings.name) {
      case AppRoutes.login:
        page = const LoginScreen();
        break;
      case AppRoutes.signup:
        page = const SignupScreen();
        break;
      case AppRoutes.home:
        page = const HomeScreen();
        break;
      case AppRoutes.map:
        page = const MapScreen();
        break;
      case AppRoutes.saved:
        page = const SavedScreen();
        break;
      case AppRoutes.profile:
        page = const ProfileScreen();
        break;
      case AppRoutes.detail:
        page = HostelDetailScreen(hostelId: settings.arguments as String);
        break;
      case AppRoutes.booking:
        final args = settings.arguments as BookingArgs;
        page = BookingScreen(
          hostelId: args.hostelId,
          roomTypeId: args.roomTypeId,
        );
        break;
      default:
        page = const SplashScreen();
    }

    // Bottom-nav tabs swap instantly.
    if (AppRoutes.tabs.contains(settings.name)) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, _, _) => page,
        transitionDuration: Duration.zero,
      );
    }
    // Splash and login fade in.
    if (settings.name == null || AppRoutes._fade.contains(settings.name)) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, _, _) => page,
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      );
    }
    return MaterialPageRoute(settings: settings, builder: (_) => page);
  }
}
