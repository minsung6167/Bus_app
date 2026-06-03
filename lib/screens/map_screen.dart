import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/terminal_coordinates.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  final String fromTerminalName;
  final String toTerminalName;

  const MapScreen({
    super.key,
    required this.fromTerminalName,
    required this.toTerminalName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  LatLng? get _fromLatLng {
    final c = findCoord(widget.fromTerminalName);
    return c != null ? LatLng(c.lat, c.lng) : null;
  }

  LatLng? get _toLatLng {
    final c = findCoord(widget.toTerminalName);
    return c != null ? LatLng(c.lat, c.lng) : null;
  }

  LatLng get _center {
    final from = _fromLatLng;
    final to = _toLatLng;
    if (from != null && to != null) {
      return LatLng(
        (from.latitude + to.latitude) / 2,
        (from.longitude + to.longitude) / 2,
      );
    }
    return from ?? to ?? const LatLng(36.5, 127.5);
  }

  double get _zoom {
    final from = _fromLatLng;
    final to = _toLatLng;
    if (from == null || to == null) return 10;
    final latDiff = (from.latitude - to.latitude).abs();
    final lngDiff = (from.longitude - to.longitude).abs();
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    if (maxDiff > 3) return 6.5;
    if (maxDiff > 1.5) return 7.5;
    return 9.0;
  }

  Set<Marker> get _markers {
    final markers = <Marker>{};
    final from = _fromLatLng;
    final to = _toLatLng;

    if (from != null) {
      markers.add(Marker(
        markerId: const MarkerId('from'),
        position: from,
        infoWindow: InfoWindow(
          title: '출발: ${widget.fromTerminalName}',
          snippet: '출발 터미널',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }
    if (to != null) {
      markers.add(Marker(
        markerId: const MarkerId('to'),
        position: to,
        infoWindow: InfoWindow(
          title: '도착: ${widget.toTerminalName}',
          snippet: '도착 터미널',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('${widget.fromTerminalName} → ${widget.toTerminalName}'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: _zoom,
            ),
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            onMapCreated: (controller) {
              _controller = controller;
              // 두 마커가 모두 있으면 자동 카메라 조정
              final from = _fromLatLng;
              final to = _toLatLng;
              if (from != null && to != null) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  _controller?.animateCamera(
                    CameraUpdate.newLatLngBounds(
                      LatLngBounds(
                        southwest: LatLng(
                          from.latitude < to.latitude ? from.latitude : to.latitude,
                          from.longitude < to.longitude ? from.longitude : to.longitude,
                        ),
                        northeast: LatLng(
                          from.latitude > to.latitude ? from.latitude : to.latitude,
                          from.longitude > to.longitude ? from.longitude : to.longitude,
                        ),
                      ),
                      100,
                    ),
                  );
                });
              }
            },
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _LegendItem(color: Colors.blue, label: '출발: ${widget.fromTerminalName}'),
                const SizedBox(width: 12),
                _LegendItem(color: Colors.red, label: '도착: ${widget.toTerminalName}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
