import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  State<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  final MapController _mapController = MapController();

  static const LatLng _initialCenter = LatLng(9.415, 79.695);
  static const double _initialZoom = 9.0;

  final List<Marker> _markers = [
    Marker(
      point: const LatLng(8.817, 79.848),
      width: 60,
      height: 60,
      child: Column(
        children: const [
          Icon(Icons.directions_boat, color: Colors.red, size: 15),
          Text('எல்லை எச்சரிக்கை', style: TextStyle(fontSize: 8)),
        ],
      ),
    ),
  ];

  void _prepareOfflineMap() {
    final bounds = LatLngBounds(
      const LatLng(8.0, 76.0),
      const LatLng(13.0, 80.0),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('கடல் வரைபடம் (OSM - Free)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _prepareOfflineMap,
            tooltip: 'ஆஃப்லைன் தயார்',
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: _initialCenter,
          initialZoom: _initialZoom,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.sea_siren_alert',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
