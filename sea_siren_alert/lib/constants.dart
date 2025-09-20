import 'package:latlong2/latlong.dart';

const String defaultLanguage = 'Tamil';
const String coastGuardNumber = '+91-1234567890'; // Update for production
const double alert5km = 5000; // Meters
const double alert2km = 2000;
const double alert500m = 500;

// Approx IMBL polygon for testing
final List<LatLng> borderPolygon = [
  LatLng(8.5, 78.0),
  LatLng(8.0, 78.5),
  LatLng(7.5, 79.0),
  LatLng(7.0, 79.5),
  LatLng(6.5, 80.0),
];