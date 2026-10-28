/// The signed-in user.
class AppUser {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String provider; // Firebase provider id or 'offline'

  const AppUser({
    required this.id,
    required this.email,
    this.name = '',
    this.photoUrl,
    this.provider = 'password',
  });

  /// Name to show in the UI.
  String get label {
    if (name.trim().isNotEmpty) return name.trim();
    return email.contains('@') ? email.split('@').first : 'Student';
  }

  String get providerLabel {
    switch (provider) {
      case 'google.com':
        return 'Signed in with Google';
      case 'apple.com':
        return 'Signed in with Apple';
      default:
        return 'Email account';
    }
  }
}
