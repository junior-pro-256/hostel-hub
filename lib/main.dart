import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/widgets/setup_error_screen.dart';
import 'firebase_options.dart';

/// Application entry point: start Firebase, then launch the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    runApp(SetupErrorScreen(details: e.toString()));
    return;
  }
  runApp(const HostelHubApp());
}
