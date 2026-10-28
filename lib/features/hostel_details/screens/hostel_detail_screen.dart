import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/services/contact_service.dart';
import '../../../core/widgets/hostel_image_carousel.dart';
import '../../../core/widgets/price_tag.dart';
import '../../../models/booking.dart';
import '../../../models/hostel.dart';
import '../../../models/room_type.dart';
import '../../../providers/hostel_provider.dart';
import '../../../providers/saved_hostels_provider.dart';
import '../widgets/amenities_grid.dart';
import '../widgets/hostel_details_header.dart';
import '../widgets/location_preview.dart';
import '../widgets/manager_card.dart';
import '../widgets/room_selector.dart';

/// Full hostel page: photos, rooms, amenities, location, manager, booking.
class HostelDetailScreen extends StatefulWidget {
  const HostelDetailScreen({super.key, required this.hostelId});

  final String hostelId;

  @override
  State<HostelDetailScreen> createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends State<HostelDetailScreen> {
  final _contact = ContactService();
  String? _selectedRoomId;

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _launch(Future<bool> Function() action, String error) async {
    try {
      if (!await action()) _snack(error);
    } catch (_) {
      _snack(error);
    }
  }

  /// Selected room, or the first available one by default.
  RoomType? _currentRoom(Hostel h) {
    for (final r in h.roomTypes) {
      if (r.id == _selectedRoomId && r.isAvailable) return r;
    }
    for (final r in h.roomTypes) {
      if (r.isAvailable) return r;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hostel = context.watch<HostelProvider>().byId(widget.hostelId);
    final saved = context.watch<SavedHostelsProvider>();

    if (hostel == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Hostel not found')),
      );
    }

    final room = _currentRoom(hostel);
    final manager = hostel.manager;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos with back / share / favorite overlay buttons.
            Stack(
              children: [
                HostelImageCarousel(
                  images: hostel.images,
                  height: AppDimensions.detailImageHeight,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.sm + 4),
                    child: Row(
                      children: [
                        _CircleButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        _CircleButton(
                          icon: Icons.share_outlined,
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: '${hostel.name} - ${hostel.address}',
                              ),
                            );
                            _snack('Hostel details copied');
                          },
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        _CircleButton(
                          icon: saved.isSaved(hostel.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: saved.isSaved(hostel.id)
                              ? AppColors.error
                              : AppColors.navy,
                          onTap: () => context
                              .read<SavedHostelsProvider>()
                              .toggle(hostel.id),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HostelDetailsHeader(hostel: hostel),
                  const _SectionTitle('Room options'),
                  RoomSelector(
                    rooms: hostel.roomTypes,
                    selectedId: room?.id,
                    onSelected: (r) => setState(() => _selectedRoomId = r.id),
                  ),
                  const _SectionTitle('Amenities'),
                  AmenitiesGrid(amenities: hostel.amenities),
                  const _SectionTitle('Location'),
                  LocationPreview(
                    address: hostel.address,
                    onTap: () => _launch(
                      () => _contact.openMap(
                        hostel.latitude,
                        hostel.longitude,
                        label: hostel.name,
                      ),
                      'Could not open Google Maps',
                    ),
                  ),
                  const _SectionTitle('Hostel manager'),
                  ManagerCard(
                    manager: manager,
                    onCall: manager.hasValidPhone
                        ? () => _launch(() => _contact.call(manager.phone),
                            'Could not open the dialer')
                        : null,
                    onWhatsApp: manager.hasValidWhatsapp
                        ? () => _launch(
                            () => _contact.whatsapp(manager.whatsapp,
                                message:
                                    'Hi, I am interested in ${hostel.name}.'),
                            'Could not open WhatsApp')
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Sticky booking bar.
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              if (room != null) ...[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    PriceTag(amount: room.pricePerSemester),
                  ],
                ),
                const SizedBox(width: AppDimensions.md),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: room == null
                      ? null
                      : () => Navigator.pushNamed(
                          context,
                          AppRoutes.booking,
                          arguments: BookingArgs(
                            hostelId: hostel.id,
                            roomTypeId: room.id,
                          ),
                        ),
                  child: Text(
                    room == null ? 'No rooms available' : AppStrings.bookNow,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppDimensions.lg,
        bottom: AppDimensions.sm + 2,
      ),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.navy,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
