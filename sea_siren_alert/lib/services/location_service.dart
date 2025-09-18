import 'package:location/location.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:sea_siren_alert/config/border_config.dart';
import 'package:sea_siren_alert/services/ai_service.dart';
import 'package:sea_siren_alert/services/alert_service.dart';
import 'package:sea_siren_alert/services/storage_service.dart';

class LocationService {
  static final Location _location = Location();

  static Future<void> startTracking(Function(LatLng) onUpdate) async {
    bool enabled = await _location.serviceEnabled();
    if (!enabled) enabled = await _location.requestService();
    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) permission = await _location.requestPermission();

    if (enabled && permission == PermissionStatus.granted) {
      _location.changeSettings(accuracy: LocationAccuracy.high, intervalMs: 1000);  // Battery-aware: Adjust interval
      _location.onLocationChanged.listen((LocationData data) {
        final pos = LatLng(data.latitude!, data.longitude!);
        onUpdate(pos);
        _checkGeofence(pos, data.speed ?? 0, data.heading ?? 0);
        StorageService.logEvent('Location: ${pos.latitude}, ${pos.longitude}');
      });
    }
  }

  static void _checkGeofence(LatLng pos, double speed