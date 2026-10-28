enum BookingType { visit, booking }

enum BookingStatus { pending, confirmed, cancelled }

/// Arguments passed when opening the booking screen.
class BookingArgs {
  final String hostelId;
  final String? roomTypeId;

  const BookingArgs({required this.hostelId, this.roomTypeId});
}

/// A visit or booking request made by a student.
class Booking {
  final String id;
  final String hostelId;
  final String roomTypeId;
  final String studentName;
  final String phone;
  final BookingType type;
  final DateTime date;
  final BookingStatus status;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.hostelId,
    required this.roomTypeId,
    required this.studentName,
    required this.phone,
    required this.type,
    required this.date,
    this.status = BookingStatus.pending,
    required this.createdAt,
  });

  Booking copyWith({BookingStatus? status}) => Booking(
        id: id,
        hostelId: hostelId,
        roomTypeId: roomTypeId,
        studentName: studentName,
        phone: phone,
        type: type,
        date: date,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  String get typeLabel => type == BookingType.visit ? 'Visit' : 'Booking';

  /// e.g. "22 Oct 2026"
  String get dateLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hostelId': hostelId,
        'roomTypeId': roomTypeId,
        'studentName': studentName,
        'phone': phone,
        'type': type.name,
        'date': date.toIso8601String(),
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: j['id'] as String,
        hostelId: j['hostelId'] as String,
        roomTypeId: j['roomTypeId'] as String,
        studentName: j['studentName'] as String,
        phone: j['phone'] as String,
        type: BookingType.values.byName(j['type'] as String),
        date: DateTime.parse(j['date'] as String),
        status: BookingStatus.values.byName(j['status'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
