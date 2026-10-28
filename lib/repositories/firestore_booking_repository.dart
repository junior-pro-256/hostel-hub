import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';
import 'booking_repository.dart';

/// Bookings live in the top-level `bookings` collection, tagged with userId.
class FirestoreBookingRepository implements BookingRepository {
  FirestoreBookingRepository(this._uid, {FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final String? Function() _uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('bookings');

  @override
  Future<List<Booking>> getBookings() async {
    final uid = _uid();
    if (uid == null) return [];
    final snap = await _col.where('userId', isEqualTo: uid).get();
    final items = <Booking>[];
    for (final doc in snap.docs) {
      try {
        items.add(Booking.fromJson(doc.data()));
      } catch (_) {}
    }
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  @override
  Future<void> saveBooking(Booking booking) async {
    final uid = _uid();
    if (uid == null) throw StateError('Not signed in');
    await _col.doc(booking.id).set({...booking.toJson(), 'userId': uid});
  }

  @override
  Future<void> updateBooking(Booking booking) =>
      _col.doc(booking.id).update({'status': booking.status.name});
}
