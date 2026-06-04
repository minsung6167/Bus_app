import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/io_client.dart';
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
  bool _locationEnabled = false;
  Set<Polyline> _polylines = {};
  String? _duration;
  bool _loadingRoute = false;
  String? _routeError;

  @override
  void initState() {
    super.initState();
    _requestLocation();
    _loadRoute();
  }

  Future<void> _requestLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기기의 위치 서비스(GPS)를 켜주세요.')),
        );
      }
      return;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }
    if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
      if (mounted) setState(() => _locationEnabled = true);
    }
  }

  Future<void> _moveToCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        14,
      ),
    );
  }

  Future<void> _loadRoute() async {
    final from = _fromLatLng;
    final to = _toLatLng;
    if (from == null || to == null) return;

    setState(() {
      _loadingRoute = true;
      _routeError = null;
    });

    // OSRM: 무료 오픈소스 라우팅, API 키 불필요, 실제 도로 경로
    const host = 'router.project-osrm.org';
    const ip = '5.148.170.168';

    // OSRM은 lng,lat 순서
    final url = Uri(
      scheme: 'https',
      host: host,
      path: '/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}',
      queryParameters: {
        'overview': 'full',
        'geometries': 'polyline',
      },
    );

    final nativeClient = HttpClient();
    // DNS를 우회하고 IP로 직접 연결, SNI는 올바른 도메인으로 설정
    nativeClient.connectionFactory =
        (Uri uri, String? proxyHost, int? proxyPort) async {
      final rawSocket = await Socket.connect(ip, 443);
      final secureSocket = await SecureSocket.secure(
        rawSocket,
        host: host,
        context: SecurityContext.defaultContext,
      );
      return ConnectionTask.fromSocket(Future.value(secureSocket), () {});
    };
    final client = IOClient(nativeClient);

    try {
      final response = await client.get(url);
      debugPrint('Directions status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final code = data['code'] as String?;
        debugPrint('OSRM code: $code');
        final routes = data['routes'] as List?;
        if (code == 'Ok' && routes != null && routes.isNotEmpty) {
          final route = routes[0];
          final encoded = route['geometry'] as String;
          final seconds = (route['legs'][0]['duration'] as num).toInt();
          final meters = (route['legs'][0]['distance'] as num).toInt();
          final duration = _formatDuration(seconds);
          final distance = '${(meters / 1000).round()}km';
          if (mounted) {
            setState(() {
              _duration = '$duration ($distance)';
              _polylines = {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: _decodePolyline(encoded),
                  color: AppColors.primary,
                  width: 5,
                ),
              };
              _loadingRoute = false;
            });
          }
          client.close();
          return;
        }
        if (mounted) {
          setState(() {
            _routeError = 'code: $code';
            _loadingRoute = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Directions error: $e');
      if (mounted) {
        setState(() {
          _routeError = '오류: $e';
          _loadingRoute = false;
        });
      }
    }

    client.close();
    if (mounted) setState(() => _loadingRoute = false);
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '$h시간 $m분';
    return '$m분';
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

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
            polylines: _polylines,
            myLocationEnabled: _locationEnabled,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            onMapCreated: (controller) {
              _controller = controller;
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
          if (_loadingRoute || _duration != null || _routeError != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
                  ],
                ),
                child: _loadingRoute
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('경로 계산 중...', style: TextStyle(fontSize: 14)),
                        ],
                      )
                    : _routeError != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 18, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '경로 오류: $_routeError',
                                  style: const TextStyle(fontSize: 13, color: Colors.red),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.directions_bus, size: 20, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                '예상 소요시간  $_duration',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          if (_locationEnabled)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _moveToCurrentLocation,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 4,
                child: const Icon(Icons.my_location),
              ),
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
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
