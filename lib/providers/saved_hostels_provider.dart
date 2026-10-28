import 'package:flutter/foundation.dart';

import '../repositories/saved_hostels_repository.dart';

/// Favorite hostel ids, stored through a repository (Firestore in the app).
class SavedHostelsProvider extends ChangeNotifier {
  SavedHostelsProvider(this._repository);

  final SavedHostelsRepository _repository;

  Set<String> _ids = {};
  String? _userId;

  Set<String> get ids => Set.unmodifiable(_ids);

  bool isSaved(String id) => _ids.contains(id);

  Future<void> load() async {
    try {
      _ids = await _repository.load();
    } catch (_) {
      _ids = {};
    }
    notifyListeners();
  }

  /// Called when someone signs in or out.
  Future<void> onUserChanged(String? uid) async {
    if (uid == _userId) return;
    _userId = uid;
    if (uid == null) {
      _ids = {};
      notifyListeners();
    } else {
      await load();
    }
  }

  Future<void> toggle(String id) async {
    final before = Set.of(_ids);
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
    try {
      await _repository.save(_ids);
    } catch (_) {
      _ids = before; // undo if saving failed
      notifyListeners();
    }
  }
}
