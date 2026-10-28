import 'package:url_launcher/url_launcher.dart';

/// Opens the phone dialer or WhatsApp. Returns false if it could not launch.
class ContactService {
  Future<bool> openMap(double latitude, double longitude, {String label = ''}) {
    final query = label.isEmpty
        ? '$latitude,$longitude'
        : '$label ($latitude,$longitude)';
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> call(String phone) {
    return launchUrl(Uri(scheme: 'tel', path: phone));
  }

  Future<bool> whatsapp(String phone, {String message = ''}) {
    final number = phone.replaceAll('+', '');
    final uri = Uri.parse(
        'https://wa.me/$number?text=${Uri.encodeComponent(message)}');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
