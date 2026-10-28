import '../core/services/storage_service.dart';

/// Where favorite hostel ids are stored.
abstract class SavedHostelsRepository {
  Future<Set<String>> load();
  Future<void> save(Set<String> ids);
}

/// On-device storage (used in tests and as an offline fallback).
class LocalSavedHostelsRepository implements SavedHostelsRepository {
  LocalSavedHostelsRepository(this._storage);

  final StorageService _storage;

  @override
  Future<Set<String>> load() async =>
      _storage.getStringList(StorageKeys.savedHostels).toSet();

  @override
  Future<void> save(Set<String> ids) =>
      _storage.setStringList(StorageKeys.savedHostels, ids.toList());
}
