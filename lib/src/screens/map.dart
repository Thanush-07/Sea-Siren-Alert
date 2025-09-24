import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/border_alert.dart';

class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});
  @override
  State<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  final MapController _mapController = MapController();

  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );

  static const LatLng _initialCenter = LatLng(9.415, 79.695);
  static const double _initialZoom = 9.0;

  // Single reference border point for demo (replace with polyline logic if needed)
  static const LatLng _borderPoint = LatLng(9.066, 79.553);

  LatLng? _boatPos;

  void _onTapMap(TapPosition tapPos, LatLng latlng) async {
    setState(() => _boatPos = latlng);
    await _applyAlerts(); // compute and show full-screen alert if within thresholds
  }

  double _distanceMeters(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(a.latitude, a.longitude, b.latitude, b.longitude);
  }

  Future<void> _applyAlerts() async {
    if (_boatPos == null) return;
    final d = _distanceMeters(_boatPos!, _borderPoint);
    if (d <= 500) {
      await BorderAlert.show(context, BorderAlertLevel.m500);
    } else if (d <= 1000) {
      await BorderAlert.show(context, BorderAlertLevel.km1);
    } else if (d <= 3000) {
      await BorderAlert.show(context, BorderAlertLevel.km3);
    }
  }

  LatLngBounds _boundsFromTwo(LatLng a, LatLng b) {
    final south = math.min(a.latitude, b.latitude);
    final west = math.min(a.longitude, b.longitude);
    final north = math.max(a.latitude, b.latitude);
    final east = math.max(a.longitude, b.longitude);
    return LatLngBounds(LatLng(south, west), LatLng(north, east));
  }

  void _fitBorderAndBoat() {
    if (!mounted) return;
    if (_boatPos == null) {
      _mapController.move(_borderPoint, 13);
      return;
    }
    final bounds = _boundsFromTwo(_borderPoint, _boatPos!);
    final camera = _mapController.camera;
    final fitted = CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.fromLTRB(36, 36, 36, 120),
      maxZoom: 16,
    ).fit(camera);
    _mapController.move(fitted.center, fitted.zoom);
  }

  // Place a temporary boat at a specific radius from border if none exists
  LatLng _pointAtDistanceFromBorder(double meters, {double bearingDeg = 90}) {
    // Simple equirectangular step (ok for a few km)
    const earthR = 6371000.0;
    final br = bearingDeg * math.pi / 180.0;
    final lat1 = _borderPoint.latitude * math.pi / 180.0;
    final lon1 = _borderPoint.longitude * math.pi / 180.0;
    final ang = meters / earthR;
    final lat2 = math.asin(math.sin(lat1) * math.cos(ang) + math.cos(lat1) * math.sin(ang) * math.cos(br));
    final lon2 = lon1 +
        math.atan2(
          math.sin(br) * math.sin(ang) * math.cos(lat1),
          math.cos(ang) - math.sin(lat1) * math.sin(lat2),
        );
    return LatLng(lat2 * 180.0 / math.pi, lon2 * 180.0 / math.pi);
  }

  Future<void> _showLevel(BorderAlertLevel level) async {
    // Ensure a visible boat position for the demo
    if (_boatPos == null) {
      // Place boat at requested ring from border to visualize context
      if (level == BorderAlertLevel.km3) {
        _boatPos = _pointAtDistanceFromBorder(3000);
      } else if (level == BorderAlertLevel.km1) {
        _boatPos = _pointAtDistanceFromBorder(1000);
      } else {
        _boatPos = _pointAtDistanceFromBorder(500);
      }
      setState(() {});
    }

    // Show full-screen alert with tone
    await BorderAlert.show(context, level);

    // Fit map so both markers are visible
    _fitBorderAndBoat();
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      Marker(
        point: _borderPoint,
        width: 110,
        height: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.flag, color: Colors.red, size: 18),
            SizedBox(height: 2),
            Text('எல்லை புள்ளி', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
      if (_boatPos != null)
        Marker(
          point: _boatPos!,
          width: 110,
          height: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.directions_boat, color: Colors.blue, size: 22),
              SizedBox(height: 2),
              Text('படகு (சோதனை)', style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('கடல் வரைபடம்')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              onTap: _onTapMap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.sea_siren_alert',
                tileProvider: _tileProvider,
              ),
              MarkerLayer(markers: markers),
              if (_boatPos != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_borderPoint, _boatPos!],
                      color: Colors.blueAccent,
                      strokeWidth: 2,
                    ),
                  ],
                ),
            ],
          ),

          // NEW: Quick Alert Level bar
          Positioned(
            right: 12,
            bottom: 84, // above any bottom nav/padding
            child: Container
              (
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3 km
                  ActionChip(
                    avatar: const Icon(Icons.circle, color: Colors.amber, size: 14),
                    label: const Text('3 கி.மீ'),
                    onPressed: () => _showLevel(BorderAlertLevel.km3),
                  ),
                  const SizedBox(width: 8),
                  // 1 km
                  ActionChip(
                    avatar: const Icon(Icons.circle, color: Colors.deepOrange, size: 14),
                    label: const Text('1 கி.மீ'),
                    onPressed: () => _showLevel(BorderAlertLevel.km1),
                  ),
                  const SizedBox(width: 8),
                  // 500 m
                  ActionChip(
                    avatar: const Icon(Icons.circle, color: Colors.red, size: 14),
                    label: const Text('500 மீ'),
                    onPressed: () => _showLevel(BorderAlertLevel.m500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Keep the judges FAB if desired (can be removed; this is optional now)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _applyAlerts();
          _fitBorderAndBoat();
        },
        backgroundColor: const Color(0xFF0E54A7),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded),
        label: const Text('எச்சரிக்கைகள் காண்க'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: _boatPos == null
          ? const SizedBox.shrink()
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'எல்லை தூரம்: ${_distanceMeters(_boatPos!, _borderPoint).toStringAsFixed(1)} மீ',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
