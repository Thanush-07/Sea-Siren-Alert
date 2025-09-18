import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sea_siren_alert/config/border_config.dart';
import 'package:sea_siren_alert/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    LocationService.startTracking((position) {
      setState(() => _currentPosition = LatLng(position.latitude, position.longitude));
      // Trigger alerts based on distance/trajectory here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sea Siren Alert')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentPosition ?? LatLng(9.0, 79.0),  // Default to Tamil Nadu coast
          initialZoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',  // Online; switch to local tiles for offline
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: getBorderCoordinates(),
                strokeWidth: 4.0,
                color: Colors.red,  // Show boundary line
              ),
            ],
          ),
          if (_currentPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentPosition!,
                  child: const Icon(Icons.boat, color: Colors.blue),
                ),
              ],
            ),
        ],
      ),
    );
  }
}