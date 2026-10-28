/// A room option inside a hostel (e.g. Single, Double).
class RoomType {
  final String id;
  final String name;
  final int pricePerSemester; // UGX
  final int availableUnits;
  final int capacity;

  const RoomType({
    required this.id,
    required this.name,
    required this.pricePerSemester,
    required this.availableUnits,
    required this.capacity,
  });

  bool get isAvailable => availableUnits > 0;

  factory RoomType.fromJson(Map<String, dynamic> j) => RoomType(
        id: j['id'] as String,
        name: j['name'] as String,
        pricePerSemester: (j['pricePerSemester'] as num).toInt(),
        availableUnits: (j['availableUnits'] as num).toInt(),
        capacity: (j['capacity'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'pricePerSemester': pricePerSemester,
        'availableUnits': availableUnits,
        'capacity': capacity,
      };
}
