import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/geofence_service.dart';

class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  State<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(9.415, 79.695),
    zoom: 9.0,
  );

  @override
  void initState() {
    super.initState();
    initGeofence();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMarkers());
  }

  Future<void> _loadMarkers() async {
    final imgConfig = createLocalImageConfiguration(context); // no fixed Size to avoid stretching
    final redMarkerIcon = await BitmapDescriptor.asset(
      imgConfig,
      'assets/images/boat-map-marker.png',
      width: 48, // or height: 48; set only one dimension
    );

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('border_warning'),
          position: const LatLng(8.817, 79.848),
          infoWindow: const InfoWindow(title: 'எல்லை எச்சரிக்கை'),
          icon: redMarkerIcon,
        ),
      };
    });
  }

  void _prepareOfflineMap() async {
    if (_controller == null) return;
    final bounds = LatLngBounds(
      southwest: const LatLng(8.0, 76.0),
      northeast: const LatLng(13.0, 80.0),
    );
    await _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('கடல் வரைபடம் (கூகுள்)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _prepareOfflineMap,
            tooltip: 'ஆஃப்லைன் தயார்',
          ),
        ],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        onMapCreated: (c) => _controller = c,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: _markers,
      ),
    );
  }
}
