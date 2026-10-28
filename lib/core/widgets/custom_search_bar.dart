import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// Rounded search field with a leading search icon.
/// Pass [initialText] to restore a previous query when a screen reopens.
class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    this.controller,
    this.initialText = '',
    this.hint = AppStrings.searchHint,
    this.onChanged,
    this.trailing,
  });

  final TextEditingController? controller;
  final String initialText;
  final String hint;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: widget.trailing,
      ),
    );
  }
}
