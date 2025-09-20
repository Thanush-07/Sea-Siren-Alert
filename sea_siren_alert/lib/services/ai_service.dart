import 'package:latlong2/latlong.dart';

class AiService {
  static Future<void> init() async {
    print('AI Service initialized');
  }

  static Future<LatLng?> predictTrajectory(List<LatLng> recentPositions) async {
    if (recentPositions.isEmpty) return null;
    if (recentPositions.length < 2) return recentPositions.last;

    LatLng last = recentPositions.last;
    LatLng secondLast = recentPositions[recentPositions.length - 2];
    double deltaLat = last.latitude - secondLast.latitude;
    double deltaLng = last.longitude - secondLast.longitude;
    return LatLng(last.latitude + deltaLat, last.longitude + deltaLng);
  }
}