import 'package:flutter/foundation.dart';

/// Build-time switches and map defaults.
class AppConfig {
  AppConfig._();

  /// Run with `--dart-define=USE_GOOGLE_MAPS=true` once an API key is set up.
  /// Default (false) uses the built-in mock campus map, so no key is needed.
  static const bool useGoogleMaps = bool.fromEnvironment('USE_GOOGLE_MAPS');

  /// Run with `--dart-define=USE_MOCK_HOSTELS=true` to skip Firestore and use
  /// the built-in sample hostels (handy before the database is seeded).
  static const bool useMockHostels = bool.fromEnvironment('USE_MOCK_HOSTELS');

  /// "Continue with Apple" is shown on iOS only.
  static bool get showAppleSignIn => defaultTargetPlatform == TargetPlatform.iOS;

  // Fallback map centre (Makerere University, Kampala).
  static const double campusLat = 0.3340;
  static const double campusLng = 32.5680;
  static const double defaultZoom = 15;
}
