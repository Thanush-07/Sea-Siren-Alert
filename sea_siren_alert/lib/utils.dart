import 'package:latlong2/latlong.dart';
import 'dart:math' show min, max;

double calculateDistanceToPolygon(LatLng point, List<LatLng> polygon) {
  double minDistance = double.infinity;
  for (int i = 0; i < polygon.length; i++) {
    LatLng p1 = polygon[i];
    LatLng p2 = polygon[(i + 1) % polygon.length];
    double dist = _distanceToSegment(point, p1, p2);
    minDistance = min(minDistance, dist);
  }
  return minDistance * 1000;
}

double _distanceToSegment(LatLng p, LatLng a, LatLng b) {
  const Distance distance = Distance();
  double distA = distance(p, a) / 1000;
  double distB = distance(p, b) / 1000;
  if (distA <= 0.00001 || distB <= 0.00001) return 0.0;

  double length = distance(a, b) / 1000;
  if (length <= 0.00001) return distA;

  double proj = ((p.latitude - a.latitude) * (b.latitude - a.latitude) +
      (p.longitude - a.longitude) * (b.longitude - a.longitude)) /
      (length * length);
  proj = max(0, min(1, proj));

  LatLng closest = LatLng(
    a.latitude + proj * (b.latitude - a.latitude),
    a.longitude + proj * (b.longitude - a.longitude),
  );
  return distance(p, closest) / 1000;
}