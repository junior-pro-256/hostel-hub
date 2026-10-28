import 'package:shared_preferences/shared_preferences.dart';

/// Keys used for local storage.
class StorageKeys {
  StorageKeys._();
  static const savedHostels = 'saved_hostel_ids';
  static const bookings = 'bookings';
}

/// Thin wrapper over SharedPreferences so the rest of the app never
/// touches the plugin directly (easy to swap or fake in tests).
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> create() async =>
      StorageService(await SharedPreferences.getInstance());

  List<String> getStringList(String key) => _prefs.getStringList(key) ?? [];

  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);
}
