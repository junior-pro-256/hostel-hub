/// Hostel manager contact details.
class Manager {
  final String id;
  final String name;
  final String phone; // international format, e.g. +256700000000
  final String whatsapp;
  final bool isVerified;
  final String? photoAsset;

  const Manager({
    required this.id,
    required this.name,
    required this.phone,
    required this.whatsapp,
    this.isVerified = false,
    this.photoAsset,
  });

  /// True when the phone number looks usable for calling.
  bool get hasValidPhone => RegExp(r'^\+?\d{9,15}$').hasMatch(phone);
  bool get hasValidWhatsapp => RegExp(r'^\+?\d{9,15}$').hasMatch(whatsapp);

  factory Manager.fromJson(Map<String, dynamic> j) => Manager(
        id: j['id'] as String,
        name: j['name'] as String,
        phone: (j['phone'] ?? '') as String,
        whatsapp: (j['whatsapp'] ?? '') as String,
        isVerified: (j['isVerified'] ?? false) as bool,
        photoAsset: j['photoAsset'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'whatsapp': whatsapp,
        'isVerified': isVerified,
        'photoAsset': photoAsset,
      };
}
