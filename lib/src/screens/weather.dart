import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import '../../utils/constants.dart';

class WeatherAlertScreen extends StatefulWidget {
  @override
  State<WeatherAlertScreen> createState() => _WeatherAlertScreenState();
}

class _WeatherAlertScreenState extends State<WeatherAlertScreen> {
  final String apiKey = '456ff6ece0d6392517f0c599a39a8b06';
  Weather? weather;
  String tideSpeed = 'N/A';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final box = Hive.box(kHiveBox);
    final cachedWeatherJson = box.get('cached_weather') as Map<String, dynamic>?;
    if (cachedWeatherJson != null) {
      // Manually reconstruct Weather (no fromJson in package)
      weather = Weather(cachedWeatherJson);  // Use constructor if available, or parse fields manually
      setState(() {});
    }
    try {
      final wf = WeatherFactory(apiKey, language: Language.ENGLISH);  // Use supported language (Tamil not available)
      weather = await wf.currentWeatherByLocation(9.415, 79.695);
      await box.put('cached_weather', weather?.toJson() ?? {});  // Assuming toJson exists; adjust if not
      setState(() {});
    } catch (e) {
      // Use cached if offline
    }
    _fetchTide();
  }

  Future<void> _fetchTide() async {
    // Placeholder; use real tide API (e.g., INCOIS)
    try {
      final response = await http.get(Uri.parse('https://api.tides.example.com?lat=9.415&lon=79.695'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        tideSpeed = data['tide_speed'].toString();
        setState(() {});
      }
    } catch (e) {
      tideSpeed = 'ஆஃப்லைன்: N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (weather == null) return const Center(child: CircularProgressIndicator());
    bool hasCyclone = (weather?.weatherMain?.contains('Storm') ?? false) || (weather?.windSpeed ?? 0) > 20;

    return Scaffold(
      appBar: AppBar(title: const Text('வானிலை எச்சரிக்கை')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('நிகழ்நேர வானிலை: ${weather?.weatherDescription ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
            Text('காற்று வேகம்: ${weather?.windSpeed ?? 0} m/s', style: const TextStyle(fontSize: 18)),
            Text('அலை வேகம்: $tideSpeed m/s', style: const TextStyle(fontSize: 18)),
            if (hasCyclone) 
              const Text('சுழல் காற்று அல்லது சிவப்பு கொடி எச்சரிக்கை!', style: TextStyle(fontSize: 20, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
