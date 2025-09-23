import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

Future<void> initGeofence() async {
  Position position = await Geolocator.getCurrentPosition();
  checkProximity(position.latitude, position.longitude);
}

Future<void> checkProximity(double lat, double lon) async {
  const borderLat = 9.421;  // IMBL example
  const borderLon = 79.703;
  double distance = Geolocator.distanceBetween(lat, lon, borderLat, borderLon);

  final player = AudioPlayer();
  if (distance < 500) {
    Vibration.vibrate(duration: 5000, amplitude: 255);  // Critical
    await player.play(AssetSource('audio/critical_alert.mp3'));  // Tamil: "எல்லை அருகில்!"
  } else if (distance < 2000) {
    Vibration.vibrate(duration: 2000);  // Urgent
    await player.play(AssetSource('audio/urgent_alert.mp3'));  // Tamil: "எச்சரிக்கை!"
  } else if (distance < 5000) {
    Vibration.vibrate(duration: 1000);  // Gentle
    await player.play(AssetSource('audio/gentle_alert.mp3'));  // Tamil: "கவனம்!"
  }
}