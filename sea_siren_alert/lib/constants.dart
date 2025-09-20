import 'package:latlong2/latlong.dart';

const String defaultLanguage = 'Tamil';  // App for Tamil people

// Approx IMBL polygon (India-Sri Lanka). Update with accurate GPS coords.
final List<LatLng> borderPolygon = [
  const LatLng(8.5, 78.0),  // Point 1 (near Tamil Nadu)
  const LatLng(8.0, 78.5),
  const LatLng(7.5, 79.0),
  const LatLng(7.0, 79.5),
  const LatLng(6.5, 80.0),  // Point near Sri Lanka
  // Add more points for accuracy. Close the polygon.
];

const double alert5km = 5000;  // Meters
const double alert2km = 2000;
const double alert500m = 500;

const String coastGuardNumber = '+91-XXXXXXXXXX';  // Update with real number