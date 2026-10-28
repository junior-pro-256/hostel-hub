import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/institution.dart';
import '../../../providers/hostel_provider.dart';

/// Bottom sheet to choose which institution's hostels to show.
Future<void> showInstitutionPicker(BuildContext context) {
  final provider = context.read<HostelProvider>();

  Widget option({
    required String title,
    String? subtitle,
    required String? value,
    required BuildContext sheetContext,
  }) {
    final selected = provider.institution == value;
    return ListTile(
      leading: Icon(Icons.school_outlined,
          color: selected ? AppColors.primary : AppColors.textSecondary),
      title: Text(title,
          style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing:
          selected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        provider.setInstitution(value);
        Navigator.pop(sheetContext);
      },
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            option(title: 'All institutions', value: null, sheetContext: sheetContext),
            for (final i in Institution.all)
              option(
                  title: i.name,
                  subtitle: i.area,
                  value: i.short,
                  sheetContext: sheetContext),
          ],
        ),
      ),
    ),
  );
}
