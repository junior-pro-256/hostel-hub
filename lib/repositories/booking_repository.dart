import 'dart:convert';

import '../core/services/storage_service.dart';
import '../models/booking.dart';

/// Booking storage contract. Swap the implementation for a REST/Firebase one
/// later without touching providers or screens.
abstract class BookingRepository {
  Future<List<Booking>> getBookings();
  Future<void> saveBooking(Booking booking);
  Future<void> updateBooking(Booking booking);
}

/// Keeps bookings on the device using StorageService.
class LocalBookingRepository implements BookingRepository {
  LocalBookingRepository(this._storage);

  final StorageService _storage;

  Future<void> _write(List<Booking> items) => _storage.setStringList(
    StorageKeys.bookings,
    items.map((b) => jsonEncode(b.toJson())).toList(),
  );

  @override
  Future<List<Booking>> getBookings() async {
    final result = <Booking>[];
    for (final raw in _storage.getStringList(StorageKeys.bookings)) {
      try {
        result.add(Booking.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {
        // Skip any entry that cannot be read instead of crashing.
      }
    }
    return result;
  }

  @override
  Future<void> saveBooking(Booking booking) async {
    // Small delay so the "submitting" state is visible (mimics a network call).
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final items = await getBookings();
    await _write([...items, booking]);
  }

  @override
  Future<void> updateBooking(Booking booking) async {
    final items = await getBookings();
    final i = items.indexWhere((b) => b.id == booking.id);
    if (i == -1) return;
    items[i] = booking;
    await _write(items);
  }
}

/// Non-persistent version, handy for tests.
class InMemoryBookingRepository implements BookingRepository {
  final List<Booking> _items = [];

  @override
  Future<List<Booking>> getBookings() async => List.of(_items);

  @override
  Future<void> saveBooking(Booking booking) async => _items.add(booking);

  @override
  Future<void> updateBooking(Booking booking) async {
    final i = _items.indexWhere((b) => b.id == booking.id);
    if (i != -1) _items[i] = booking;
  }
}
