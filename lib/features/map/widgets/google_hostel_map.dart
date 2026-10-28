import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_config.dart';
import '../../../models/hostel.dart';
import 'hostel_price_marker.dart';

/// Real Google Map with custom price markers.
/// Needs an API key (see README) and `--dart-define=USE_GOOGLE_MAPS=true`.
class GoogleHostelMap extends StatefulWidget {
  const GoogleHostelMap({
    super.key,
    required this.hostels,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Hostel> hostels;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  State<GoogleHostelMap> createState() => _GoogleHostelMapState();
}

class _GoogleHostelMapState extends State<GoogleHostelMap> {
  GoogleMapController? _controller;
  final Map<String, BitmapDescriptor> _icons = {};

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  @override
  void didUpdateWidget(covariant GoogleHostelMap old) {
    super.didUpdateWidget(old);
    _loadIcons();
    if (old.selectedId != widget.selectedId) _moveToSelected();
  }

  String _key(Hostel h, bool selected) => '${h.startingPrice}|$selected';

  /// Draw marker bitmaps once per price/selected combination.
  Future<void> _loadIcons() async {
    var added = false;
    for (final h in widget.hostels) {
      for (final selected in [false, true]) {
        final key = _key(h, selected);
        if (_icons.containsKey(key)) continue;
        _icons[key] =
            await HostelPriceMarker.toBitmap(h.startingPrice, selected: selected);
        added = true;
      }
    }
    if (added && mounted) setState(() {});
  }

  void _moveToSelected() {
    for (final h in widget.hostels) {
      if (h.id == widget.selectedId) {
        _controller?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(h.latitude, h.longitude),
                AppConfig.defaultZoom));
      }
    }
  }

  /// Start on the first visible hostel, or the default centre if none.
  LatLng get _initialTarget => widget.hostels.isEmpty
      ? const LatLng(AppConfig.campusLat, AppConfig.campusLng)
      : LatLng(widget.hostels.first.latitude, widget.hostels.first.longitude);

  @override
  Widget build(BuildContext context) {
    final markers = widget.hostels.map((h) {
      final selected = h.id == widget.selectedId;
      return Marker(
        markerId: MarkerId(h.id),
        position: LatLng(h.latitude, h.longitude),
        icon: _icons[_key(h, selected)] ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(0.5, 1),
        onTap: () => widget.onSelect(h.id),
      );
    }).toSet();

    return GoogleMap(
      initialCameraPosition:
          CameraPosition(target: _initialTarget, zoom: AppConfig.defaultZoom),
      markers: markers,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: (c) => _controller = c,
    );
  }
}
