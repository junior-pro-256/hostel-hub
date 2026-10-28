import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/price_tag.dart';
import '../../../models/booking.dart';
import '../../../models/hostel.dart';
import '../../../providers/booking_provider.dart';

typedef BookingSubmit = void Function({
  required String name,
  required String phone,
  required String roomTypeId,
  required BookingType type,
  required DateTime date,
});

/// Form for a visit or booking request. Validation lives in BookingProvider.
class BookingForm extends StatefulWidget {
  const BookingForm({
    super.key,
    required this.hostel,
    required this.initialRoomId,
    required this.isSubmitting,
    required this.onSubmit,
    this.errorMessage,
    this.initialName = '',
  });

  final Hostel hostel;
  final String? initialRoomId;
  final bool isSubmitting;
  final String? errorMessage;
  final BookingSubmit onSubmit;
  final String initialName;

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  BookingType _type = BookingType.visit;
  DateTime? _date;
  String? _roomId;
  bool _dateTouched = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    final available = widget.hostel.roomTypes.where((r) => r.isAvailable);
    _roomId = available.any((r) => r.id == widget.initialRoomId)
        ? widget.initialRoomId
        : (available.isEmpty ? null : available.first.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    setState(() => _dateTouched = true);
    final valid = _formKey.currentState!.validate();
    if (!valid || BookingProvider.validateDate(_date) != null || _roomId == null) {
      return;
    }
    widget.onSubmit(
      name: _nameController.text,
      phone: _phoneController.text,
      roomTypeId: _roomId!,
      type: _type,
      date: _date!,
    );
  }

  String _dateText() {
    final d = _date;
    if (d == null) return 'Select date';
    return Booking(
      id: '', hostelId: '', roomTypeId: '', studentName: '', phone: '',
      type: _type, date: d, createdAt: d,
    ).dateLabel;
  }

  @override
  Widget build(BuildContext context) {
    final rooms = widget.hostel.roomTypes.where((r) => r.isAvailable).toList();
    final dateError = _dateTouched ? BookingProvider.validateDate(_date) : null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<BookingType>(
            segments: const [
              ButtonSegment(
                  value: BookingType.visit,
                  icon: Icon(Icons.event_outlined),
                  label: Text('Schedule visit')),
              ButtonSegment(
                  value: BookingType.booking,
                  icon: Icon(Icons.bed_outlined),
                  label: Text('Book room')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: AppDimensions.md),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Full name'),
            validator: BookingProvider.validateName,
          ),
          const SizedBox(height: AppDimensions.md),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
                labelText: 'Phone number', hintText: '+256 700 000 000'),
            validator: BookingProvider.validatePhone,
          ),
          const SizedBox(height: AppDimensions.md),
          DropdownButtonFormField<String>(
            initialValue: _roomId,
            decoration: const InputDecoration(labelText: 'Room type'),
            items: rooms
                .map((r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(
                          '${r.name} - UGX ${PriceTag.format(r.pricePerSemester)}'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _roomId = v),
            validator: (v) => v == null ? 'Choose a room' : null,
          ),
          const SizedBox(height: AppDimensions.md),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: _type == BookingType.visit
                    ? 'Visit date'
                    : 'Move-in date',
                errorText: dateError,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(_dateText()),
            ),
          ),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: AppDimensions.md),
            Text(widget.errorMessage!,
                style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: AppDimensions.lg),
          ElevatedButton(
            onPressed: widget.isSubmitting ? null : _submit,
            child: widget.isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(_type == BookingType.visit
                    ? 'Request visit'
                    : 'Submit booking request'),
          ),
        ],
      ),
    );
  }
}
