import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class WeatherAlertScreen extends StatefulWidget {
  const WeatherAlertScreen({super.key});
  @override
  State<WeatherAlertScreen> createState() => _WeatherAlertScreenState();
}

class _WeatherAlertScreenState extends State<WeatherAlertScreen> {
  // Berlin sample from your link
  static const double _lat = 52.52;
  static const double _lon = 13.41;

  Map<String, dynamic>? _weather;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refreshWeather();
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

  Future<void> _saveToCache(Map<String, dynamic> data) async {
    final box = Hive.box('fisherman_box');
    await box.put('weather', data);
  }

  Future<Map<String, dynamic>?> _loadFromCache() async {
    final box = Hive.box('fisherman_box');
    return _asStringKeyedMap(box.get('weather'));
  }

  Uri _buildMarineUri() {
    // Correct parameter names, no markdown commas, no trailing spaces
    // Using timezone=auto and explicit start/end dates if desired
    return Uri.https(
      'api.open-meteo.com',
      '/v1/marine',
      {
        'latitude': _lat.toString(),
        'longitude': _lon.toString(),
        'hourly': 'wind_speed_10m,wave_height,wave_period,sea_level_height_msl',
        'start_date': '2025-09-25',
        'end_date': '2025-10-10',
        'timezone': 'auto',
        'cell_selection': 'sea',
      },
    );
  }

  List<Map<String, String>> _hourlyToCards(Map<String, dynamic> m) {
    final hourly = m['hourly'] as Map<String, dynamic>? ?? {};
    final times = (hourly['time'] as List?)?.cast<String>() ?? const <String>[];
    final waves = (hourly['wave_height'] as List?)?.cast<num>() ?? const <num>[];
    final period = (hourly['wave_period'] as List?)?.cast<num>() ?? const <num>[];
    final sea = (hourly['sea_level_height_msl'] as List?)?.cast<num>() ?? const <num>[];
    final wind = (hourly['wind_speed_10m'] as List?)?.cast<num>() ?? const <num>[];

    final out = <Map<String, String>>[];
    final n = times.length;
    for (var i = 0; i < n && i < 12; i++) {
      final t = times[i];
      final waveM = i < waves.length ? waves[i].toStringAsFixed(1) : '—';
      final perS = i < period.length ? period[i].toStringAsFixed(0) : '—';
      final seaM = i < sea.length ? sea[i].toStringAsFixed(2) : '—';
      final windKts = i < wind.length ? (wind[i] * 1.94384).toStringAsFixed(1) : '—'; // m/s -> kts
      out.add({
        'title': t,
        'description': 'அலை உயரம்: $waveM m • அலை காலம்: $perS s • கடல் மட்டம்: $seaM m • காற்று: $windKts kts',
      });
    }
    return out;
  }

  Future<Map<String, dynamic>> _fetchFromApi() async {
    final uri = _buildMarineUri();
    final resp = await http.get(uri).timeout(const Duration(seconds: 12));
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }
    final decoded = jsonDecode(resp.body);
    if (decoded is! Map) {
      throw Exception('Invalid JSON shape');
    }
    final map = Map<String, dynamic>.from(decoded);

    // Build display list for this screen
    map['alerts'] = _hourlyToCards(map);

    // Snapshot fields for Home header (optional)
    try {
      final hourly = map['hourly'] as Map<String, dynamic>;
      final wind = (hourly['wind_speed_10m'] as List).cast<num>();
      final sea = (hourly['sea_level_height_msl'] as List).cast<num>();
      final windKts = wind.isNotEmpty ? (wind.first * 1.94384) : null;
      final tideM = sea.isNotEmpty ? sea.first : null;
      String trend = '—';
      if (sea.length >= 2) {
        final diff = sea[1] - sea[0];
        trend = diff > 0 ? 'Rising' : (diff < 0 ? 'Falling' : 'Steady');
      }
      map['wind_speed_kts'] = windKts?.toStringAsFixed(1) ?? '—';
      map['tide_height_m'] = tideM?.toStringAsFixed(2) ?? '—';
      map['tide_trend'] = trend;
    } catch (_) {}

    return map;
  }

  Future<void> _refreshWeather() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fresh = await _fetchFromApi();
      await _saveToCache(fresh);
      setState(() {
        _weather = fresh;
        _error = null;
      });
    } catch (e) {
      final cached = await _loadFromCache();
      if (cached != null) {
        setState(() {
          _weather = cached;
          _error = 'இணையம் இல்லை — சேமித்த தரவு காட்டப்படுகிறது';
        });
      } else {
        setState(() {
          _weather = {};
          _error = 'தரவுகளை பெற முடியவில்லை: $e';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = const Text('வானிலை எச்சரிக்கை');
    if (_loading && _weather == null) {
      return Scaffold(appBar: AppBar(title: title), body: const Center(child: CircularProgressIndicator()));
    }
    if (_weather == null) {
      return Scaffold(appBar: AppBar(title: title), body: Center(child: Text(_error ?? 'No data')));
    }
    final alerts = (_weather!['alerts'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(title: title),
      body: RefreshIndicator(
        onRefresh: _refreshWeather,
        child: alerts.isEmpty
            ? ListView(
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('எச்சரிக்கைகள் இல்லை'),
            ),
          ],
        )
            : ListView.builder(
          itemCount: alerts.length,
          itemBuilder: (context, i) {
            final a = alerts[i];
            final t = a is Map && a['title'] is String ? a['title'] as String : 'Alert';
            final d = a is Map && a['description'] is String ? a['description'] as String : '';
            return ListTile(
              title: Text(t),
              subtitle: Text(d),
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            );
          },
        ),
      ),
      bottomNavigationBar: (_error != null)
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
      )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshWeather,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
