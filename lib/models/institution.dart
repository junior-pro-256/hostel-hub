/// A university or institute that hostels are located near.
class Institution {
  final String short; // key used by Hostel.institution
  final String name;
  final String area;

  const Institution({
    required this.short,
    required this.name,
    required this.area,
  });

  static const List<Institution> all = [
    Institution(short: 'Makerere', name: 'Makerere University', area: 'Kikoni / Wandegeya'),
    Institution(short: 'Kyambogo', name: 'Kyambogo University', area: 'Banda / Kyambogo'),
    Institution(short: 'MUBS', name: 'Makerere University Business School', area: 'Nakawa'),
    Institution(short: 'UICT', name: 'Uganda Institute of Information and Communications Technology', area: 'Nakawa'),
  ];

  static Institution? byShort(String? short) {
    for (final i in all) {
      if (i.short == short) return i;
    }
    return null;
  }
}
