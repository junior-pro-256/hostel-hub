import 'manager.dart';
import 'room_type.dart';

/// Core hostel listing.
class Hostel {
  final String id;
  final String name;
  final String address;
  final String institution; // short name, see Institution.all
  final String description;
  final double distanceKm; // distance to the institution
  final double rating;
  final int reviewCount;
  final List<String> images; // asset paths or http(s) URLs
  final List<RoomType> roomTypes;
  final List<String> amenities;
  final Manager manager;
  final double latitude;
  final double longitude;

  const Hostel({
    required this.id,
    required this.name,
    required this.address,
    required this.institution,
    required this.description,
    required this.distanceKm,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.roomTypes,
    required this.amenities,
    required this.manager,
    required this.latitude,
    required this.longitude,
  });

  /// Cheapest room price, used for badges and markers.
  int get startingPrice => roomTypes.isEmpty
      ? 0
      : roomTypes
          .map((r) => r.pricePerSemester)
          .reduce((a, b) => a < b ? a : b);

  /// e.g. "0.4 km to Makerere"
  String get distanceLabel => '$distanceKm km to $institution';

  bool get hasAvailability => roomTypes.any((r) => r.isAvailable);

  factory Hostel.fromJson(Map<String, dynamic> j) => Hostel(
        id: j['id'] as String,
        name: j['name'] as String,
        address: (j['address'] ?? '') as String,
        institution: (j['institution'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        distanceKm: (j['distanceKm'] as num).toDouble(),
        rating: (j['rating'] as num).toDouble(),
        reviewCount: (j['reviewCount'] as num).toInt(),
        images: List<String>.from(j['images'] ?? const []),
        roomTypes: (j['roomTypes'] as List? ?? const [])
            .map((e) => RoomType.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        amenities: List<String>.from(j['amenities'] ?? const []),
        manager:
            Manager.fromJson(Map<String, dynamic>.from(j['manager'] as Map)),
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'institution': institution,
        'description': description,
        'distanceKm': distanceKm,
        'rating': rating,
        'reviewCount': reviewCount,
        'images': images,
        'roomTypes': roomTypes.map((r) => r.toJson()).toList(),
        'amenities': amenities,
        'manager': manager.toJson(),
        'latitude': latitude,
        'longitude': longitude,
      };
}
