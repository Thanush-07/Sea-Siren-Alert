import 'package:latlong2/latlong.dart';

List<LatLng> getBorderCoordinates() {
  // IMBL points (decimal degrees) from India-Sri Lanka agreements
  // Palk Bay (Historic Waters)
  return [
    LatLng(10.0833, 80.0500),  // Position 1
    LatLng(9.9500, 79.5833),   // Position 2
    LatLng(9.6708, 79.3833),   // Position 3
    LatLng(9.3633, 79.5117),   // Position 4
    LatLng(9.2167, 79.5333),   // Position 5
    LatLng(9.1000, 79.5333),   // Position 6
    // Gulf of Mannar (continues from Position 6)
    LatLng(9.0000, 79.5217),   // 2m
    LatLng(8.8833, 79.4883),   // 3m
    LatLng(8.6667, 79.3033),   // 4m
    LatLng(8.6200, 79.2167),   // 5m
    LatLng(8.5200, 79.0783),   // 6m
    LatLng(8.3700, 78.9233),   // 7m
    LatLng(8.2033, 78.8950),   // 8m
    LatLng(7.5883, 78.7617),   // 9m
    LatLng(7.3500, 78.6467),   // 10m
    LatLng(6.5133, 78.2033),   // 11m
    LatLng(5.8983, 77.8450),   // 12m
    LatLng(5.0000, 77.1767),   // 13m
    // Bay of Bengal (starts from Position 1)
    LatLng(10.0967, 80.0833),  // 1ba
    LatLng(10.1400, 80.1583),  // 1bb
    LatLng(10.5500, 80.7667),  // 2b
    LatLng(10.6950, 81.0417),  // 3b
    LatLng(11.0450, 81.9333),  // 4b
    LatLng(11.2667, 82.4067),  // 5b
    LatLng(11.4433, 83.3667),  // 6b
  ];
}