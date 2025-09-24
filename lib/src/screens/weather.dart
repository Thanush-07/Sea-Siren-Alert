import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class WeatherAlertScreen extends StatefulWidget {
  const WeatherAlertScreen({super.key});
  @override
  State<WeatherAlertScreen> createState() => _WeatherAlertScreenState();
}

class _WeatherAlertScreenState extends State<WeatherAlertScreen> {
  Map<String, dynamic>? _weather;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
    if (value == null) return null;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  Future<void> _loadWeather() async {
    try {
      final box = Hive.box('fisherman_box');
      final raw = box.get('weather');
      final map = _asStringKeyedMap(raw);
      if (map == null) {
        setState(() {
          _weather = {};
          _error = 'No weather data';
        });
        return;
      }
      final alerts = (map['alerts'] as List?)?.map((e) {
        if (e is Map) return Map<String, dynamic>.from(e);
        return e;
      }).toList();

      setState(() {
        _weather = map..['alerts'] = alerts ?? [];
        _error = null;
      });
    } catch (e) {
      setState(() => _error = 'Failed to load weather: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('வானிலை எச்சரிக்கை')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_weather == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('வானிலை எச்சரிக்கை')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final alerts = (_weather!['alerts'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('வானிலை எச்சரிக்கை')),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, i) {
          final a = alerts[i];
          final title = a is Map && a['title'] is String ? a['title'] as String : 'Alert';
          final desc = a is Map && a['description'] is String ? a['description'] as String : '';
          return ListTile(
            title: Text(title),
            subtitle: Text(desc),
            leading: const Icon(Icons.warning_amber_rounded),
          );
        },
      ),
    );
  }
}
