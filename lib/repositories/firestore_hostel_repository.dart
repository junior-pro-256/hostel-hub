import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hostel.dart';
import 'hostel_repository.dart';

/// Reads the `hostels` collection. Fill it with backend/seed (see README).
class FirestoreHostelRepository implements HostelRepository {
  FirestoreHostelRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<List<Hostel>> getHostels() async {
    // Do not order in Firestore: orderBy excludes documents that do not have
    // an `order` field, which made otherwise valid listings disappear. Sort
    // locally instead so older/manual records remain visible too.
    final snap = await _db.collection('hostels').get();
    final hostels = <Hostel>[];
    final docs = [...snap.docs]
      ..sort((a, b) {
        final aOrder = a.data()['order'];
        final bOrder = b.data()['order'];
        final byOrder = (aOrder is num ? aOrder : double.maxFinite).compareTo(
          bOrder is num ? bOrder : double.maxFinite,
        );
        return byOrder != 0 ? byOrder : a.id.compareTo(b.id);
      });
    for (final doc in docs) {
      try {
        hostels.add(Hostel.fromJson({...doc.data(), 'id': doc.id}));
      } catch (_) {
        // Skip a malformed document instead of failing the whole list.
      }
    }
    return hostels;
  }

}
