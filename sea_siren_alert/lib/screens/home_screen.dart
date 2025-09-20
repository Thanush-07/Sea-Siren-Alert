import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/gps_service.dart';
import '../services/alert_service.dart';
import '../services/sms_service.dart';
import '../services/ai_service.dart';
import '../services/log_service.dart';
import '../constants.dart';
import '../utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(8.5, 78.0);
  final List<LatLng> _recentPositions = [];
  StreamSubscription<LatLng>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _startTracking();
  }

  Future<void> _initializeServices() async {
    await GpsService.init();
    await AlertService.init();
    await AiService.init();
  }

  void _startTracking() {
    _positionSubscription = GpsService.getPositionStream().listen((pos) async {
      setState(() {
        _currentPosition = pos;
        _recentPositions.add(pos);
        if (_recentPositions.length > 5) _recentPositions.removeAt(0);
      });
      _mapController.move(_currentPosition, 10.0);
      await _checkGeofence(pos);
    });
  }

  Future<void> _checkGeofence(LatLng pos) async {
    var predictedPos = await AiService.predictTrajectory(_recentPositions);
    double distToBorder = calculateDistanceToPolygon(predictedPos ?? pos, borderPolygon);
    String logData = 'Pos: ${pos.latitude},${pos.longitude}, Dist: $distToBorder';
    await LogService.logEvent('Position Update', logData);

    if (distToBorder <= alert500m) {
      await AlertService.triggerCriticalAlert(context);
      await LogService.logEvent('Critical Alert', logData);
      await SmsService.sendToCoastGuard(context, pos);
    } else if (distToBorder <= alert2km) {
      await AlertService.triggerUrgentAlert();
      await LogService.logEvent('Urgent Alert', logData);
    } else if (distToBorder <= alert5km) {
      await AlertService.triggerGentleAlert();
      await LogService.logEvent('Gentle Alert', logData);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sea Siren Alert - முகப்பு')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _currentPosition,
          zoom: 10.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'assets/offline_tiles/{z}/{x}/{y}.png',
            subdomains: const [],
            tileProvider: AssetTileProvider(),
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: borderPolygon,
                strokeWidth: 4.0,
                color: Colors.red,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition,
                child: const Icon(Icons.directions_boat, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}