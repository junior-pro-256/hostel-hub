import 'package:flutter/foundation.dart';

import '../models/hostel.dart';
import '../models/institution.dart';
import '../repositories/hostel_repository.dart';

enum LoadStatus { loading, loaded, error }

/// Loads hostels and applies the search text + selected filter.
class HostelProvider extends ChangeNotifier {
  HostelProvider(this._repository);

  final HostelRepository _repository;

  List<Hostel> _all = [];
  LoadStatus _status = LoadStatus.loading;
  String? _error;
  String _query = '';
  String _filter = 'All';
  String? _institution; // null = all institutions
  String? _userId;

  LoadStatus get status => _status;
  String? get error => _error;
  String get filter => _filter;
  String get query => _query;
  String? get institution => _institution;

  /// Text shown in the Home location selector.
  String get institutionLabel =>
      Institution.byShort(_institution)?.name ?? 'All institutions';
  List<Hostel> get allHostels => _all;

  /// Hostels after search + filter are applied.
  List<Hostel> get hostels {
    final q = _query.trim().toLowerCase();
    return _all.where((h) {
      final matchesQuery = q.isEmpty ||
          h.name.toLowerCase().contains(q) ||
          h.address.toLowerCase().contains(q);
      final matchesInstitution =
          _institution == null || h.institution == _institution;
      return matchesQuery && matchesInstitution && _matchesFilter(h);
    }).toList();
  }

  bool _matchesFilter(Hostel h) {
    switch (_filter) {
      case 'All':
        return true;
      case 'Under 1M':
        return h.startingPrice < 1000000;
      case 'Near campus':
        return h.distanceKm <= 0.5;
      default: // a room-type name such as Single / Double
        return h.roomTypes.any((r) => r.name == _filter);
    }
  }

  Hostel? byId(String id) {
    for (final h in _all) {
      if (h.id == id) return h;
    }
    return null;
  }

  /// Loads hostels once someone is signed in (Firestore needs a signed-in user).
  Future<void> onUserChanged(String? uid) async {
    if (uid == _userId) return;
    _userId = uid;
    if (uid != null) await load();
  }

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _all = await _repository.getHostels();
      _status = LoadStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setInstitution(String? short) {
    _institution = short;
    notifyListeners();
  }

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }
}
