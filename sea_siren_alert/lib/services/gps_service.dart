import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GpsService {
  static Future<void> init() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services disabled');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied');
        return;
      }
    }
  }

  static Stream<LatLng> getPositionStream() {
    // For development/testing: simulated movement
    return Stream.periodic(const Duration(seconds: 5), (count) {
      double lat = 8.5 - (count * 0.05);
      double lng = 78.0 + (count * 0.05);
      return LatLng(lat, lng);
    });
    
    // For production: uncomment the code below and comment out the simulated stream above
    // return Geolocator.getPositionStream(
    //   locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    // ).map((pos) => LatLng(pos.latitude, pos.longitude));
  }
}