import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../repositories/booking_repository.dart';

enum SubmitStatus { idle, submitting, success, error }

/// Validates and manages visit/booking requests.
class BookingProvider extends ChangeNotifier {
  BookingProvider(this._repository);

  final BookingRepository _repository;

  List<Booking> _bookings = [];
  SubmitStatus _status = SubmitStatus.idle;
  String? _error;
  String? _userId;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  SubmitStatus get status => _status;
  String? get error => _error;

  // ---- Validation (returns an error message, or null when valid) ----

  static String? validateName(String? v) =>
      (v == null || v.trim().length < 2) ? 'Enter your full name' : null;

  static String? validatePhone(String? v) {
    final cleaned = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
    return RegExp(r'^\+?\d{9,15}$').hasMatch(cleaned)
        ? null
        : 'Enter a valid phone number';
  }

  static String? validateDate(DateTime? d) {
    if (d == null) return 'Pick a date';
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return d.isBefore(start) ? 'Date cannot be in the past' : null;
  }

  // ---- Actions ----

  Future<void> load() async {
    try {
      _bookings = await _repository.getBookings();
    } catch (_) {
      _bookings = [];
    }
    notifyListeners();
  }

  /// Called when someone signs in or out.
  Future<void> onUserChanged(String? uid) async {
    if (uid == _userId) return;
    _userId = uid;
    if (uid == null) {
      _bookings = [];
      _status = SubmitStatus.idle;
      _error = null;
      notifyListeners();
    } else {
      await load();
    }
  }

  void reset() {
    _status = SubmitStatus.idle;
    _error = null;
    notifyListeners();
  }

  /// Returns true when the request was saved.
  Future<bool> submit({
    required String hostelId,
    required String roomTypeId,
    required String studentName,
    required String phone,
    required BookingType type,
    required DateTime date,
  }) async {
    if (_status == SubmitStatus.submitting) return false; // ignore double taps

    final problem = validateName(studentName) ??
        validatePhone(phone) ??
        validateDate(date);
    if (problem != null) {
      _status = SubmitStatus.error;
      _error = problem;
      notifyListeners();
      return false;
    }

    _status = SubmitStatus.submitting;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final booking = Booking(
        id: now.microsecondsSinceEpoch.toString(),
        hostelId: hostelId,
        roomTypeId: roomTypeId,
        studentName: studentName.trim(),
        phone: phone.replaceAll(RegExp(r'[\s-]'), ''),
        type: type,
        date: date,
        createdAt: now,
      );
      await _repository.saveBooking(booking);
      _bookings = [..._bookings, booking];
      _status = SubmitStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = SubmitStatus.error;
      _error = 'Could not send your request. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> cancel(String id) async {
    final i = _bookings.indexWhere((b) => b.id == id);
    if (i == -1) return;
    final updated = _bookings[i].copyWith(status: BookingStatus.cancelled);
    await _repository.updateBooking(updated);
    _bookings = List.of(_bookings)..[i] = updated;
    notifyListeners();
  }
}
