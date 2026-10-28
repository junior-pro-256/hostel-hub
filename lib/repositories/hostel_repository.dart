import '../data/mock_hostel_data.dart';
import '../models/hostel.dart';

/// Screens and providers depend on this interface only.
/// Swap MockHostelRepository for a REST/Firebase version later.
abstract class HostelRepository {
  Future<List<Hostel>> getHostels();
}

class MockHostelRepository implements HostelRepository {
  @override
  Future<List<Hostel>> getHostels() async {
    // Small delay so the loading state is visible during development.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return MockHostelData.hostels;
  }
}
