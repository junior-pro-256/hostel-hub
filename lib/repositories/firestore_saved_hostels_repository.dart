import 'package:cloud_firestore/cloud_firestore.dart';

import 'saved_hostels_repository.dart';

/// Favorites stored on the user's profile: users/{uid}.savedHostelIds
class FirestoreSavedHostelsRepository implements SavedHostelsRepository {
  FirestoreSavedHostelsRepository(this._uid, {FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final String? Function() _uid;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = _uid();
    return uid == null ? null : _db.collection('users').doc(uid);
  }

  @override
  Future<Set<String>> load() async {
    final doc = _doc;
    if (doc == null) return {};
    final snap = await doc.get();
    return List<String>.from(snap.data()?['savedHostelIds'] ?? const []).toSet();
  }

  @override
  Future<void> save(Set<String> ids) async {
    final doc = _doc;
    if (doc == null) throw StateError('Not signed in');
    await doc.set({'savedHostelIds': ids.toList()}, SetOptions(merge: true));
  }
}
