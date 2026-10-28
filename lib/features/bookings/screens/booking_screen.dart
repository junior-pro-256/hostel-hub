import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routing/app_router.dart';
import '../../../models/booking.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/hostel_provider.dart';
import '../widgets/booking_form.dart';

/// Visit / booking request screen with a success state.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.hostelId, this.roomTypeId});

  final String hostelId;
  final String? roomTypeId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    // Clear any previous success/error when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BookingProvider>().reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hostel = context.watch<HostelProvider>().byId(widget.hostelId);
    final bookings = context.watch<BookingProvider>();

    if (hostel == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Hostel not found')),
      );
    }

    if (bookings.status == SubmitStatus.success) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle,
                    size: 80, color: AppColors.success),
                const SizedBox(height: AppDimensions.md),
                Text('Request sent!',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  '${hostel.manager.name} will contact you to confirm.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppDimensions.xl),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.profile, (r) => false),
                  child: const Text('View my bookings'),
                ),
                const SizedBox(height: AppDimensions.sm),
                TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.home, (r) => false),
                  child: const Text('Back to home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Book / Schedule Visit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hostel.name, style: Theme.of(context).textTheme.titleLarge),
            Text(hostel.address, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppDimensions.lg),
            BookingForm(
              hostel: hostel,
              initialRoomId: widget.roomTypeId,
              initialName: context.watch<AuthProvider>().user?.name ?? '',
              isSubmitting: bookings.status == SubmitStatus.submitting,
              errorMessage:
                  bookings.status == SubmitStatus.error ? bookings.error : null,
              onSubmit: ({
                required String name,
                required String phone,
                required String roomTypeId,
                required BookingType type,
                required DateTime date,
              }) {
                context.read<BookingProvider>().submit(
                      hostelId: hostel.id,
                      roomTypeId: roomTypeId,
                      studentName: name,
                      phone: phone,
                      type: type,
                      date: date,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
