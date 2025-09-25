import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive/hive.dart';
import '../widgets/border_alert.dart';
import '../widgets/recent_alerts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Offline map download state
  bool _downloading = false;
  int? _totalTiles;
  int _attemptedTiles = 0;

  // TN coastal bounding box (adjust as needed)
  static const LatLng _sw = LatLng(8.0, 76.0);
  static const LatLng _ne = LatLng(13.0, 80.0);
  static const int _minZoom = 7;
  static const int _maxZoom = 11;

  // Border reference (replace with polyline min-distance if available)
  static const LatLng _borderPoint = LatLng(8.817, 79.848);

  StreamSubscription<Position>? _posSub;
  Position? _lastPos;        // live GPS
  double? _lastBorderMeters; // live distance to border

  @override
  void initState() {
    super.initState();
    _startBorderStream();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  Map<String, dynamic> _readWeatherMap() {
    final box = Hive.box('fisherman_box');
    final raw = box.get('weather');
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  void _startBorderStream() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;

    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 25,
    );

    _posSub = Geolocator.getPositionStream(locationSettings: settings).listen((p) async {
      _lastPos = p;
      final d = Geolocator.distanceBetween(
          p.latitude, p.longitude, _borderPoint.latitude, _borderPoint.longitude);
      _lastBorderMeters = d;

      // Full-screen threshold alerts
      if (d <= 500) {
        await BorderAlert.show(context, BorderAlertLevel.m500);
      } else if (d <= 1000) {
        await BorderAlert.show(context, BorderAlertLevel.km1);
      } else if (d <= 3000) {
        await BorderAlert.show(context, BorderAlertLevel.km3);
      }

      if (mounted) setState(() {});
    }, onError: (_) {});
  }

  Future<void> _downloadTNRegion() async {
    if (_downloading) return;
    setState(() {
      _downloading = true;
      _totalTiles = null;
      _attemptedTiles = 0;
    });

    final store = FMTCStore('mapStore');
    try {
      final bounds = LatLngBounds(_sw, _ne);
      final rectangle = RectangleRegion(bounds);

      final region = rectangle.toDownloadable(
        minZoom: _minZoom,
        maxZoom: _maxZoom,
        options: TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.sea_siren_alert',
        ),
      );

      final count = await store.download.countTiles(region);
      setState(() => _totalTiles = count);

      final result = store.download.startForeground(region: region);
      await for (final p in result.downloadProgress) {
        if (!mounted) break;
        setState(() {
          _attemptedTiles = p.attemptedTilesCount;
          _totalTiles = p.maxTilesCount;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ஆஃப்லைன் வரைபடம் தயார்')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('பதிவிறக்கம் தோல்வி: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _downloading = false);
    }
  }

  Future<void> _openMapWithOffline() async {
    await _downloadTNRegion();
    if (!mounted) return;
    Navigator.of(context).pushNamed('/map');
  }

  // UI helpers
  Widget _statChip({
    required IconData icon,
    required Color tint,
    required String titleTa,
    required String value,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tint.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titleTa, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.teal.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickTile({
    required IconData icon,
    required String titleTa,
    required VoidCallback onTap,
    Color? bg,
    Color? fg,
  }) {
    final background = bg ?? Colors.white;
    final foreground = fg ?? Colors.blueGrey.shade700;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 28),
              const SizedBox(height: 10),
              Text(titleTa, style: TextStyle(fontSize: 14, color: foreground)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Weather values
    final w = _readWeatherMap();
    final windKts = (w['wind_speed_kts'] ?? w['windKts'] ?? '—').toString();
    final windDir = (w['wind_dir_text'] ?? w['windDir'] ?? '—').toString();
    final tideM = (w['tide_height_m'] ?? w['tideM'] ?? '—').toString();
    final tideTrend = (w['tide_trend'] ?? w['tideTrend'] ?? '—').toString();

    final pct = (_totalTiles == null || _totalTiles == 0)
        ? null
        : _attemptedTiles / _totalTiles!.clamp(1, 1 << 30);

    // Live border distance label
    String borderText;
    if (_lastBorderMeters == null) {
      borderText = 'இடம் பெறப்படுகிறது...';
    } else if (_lastBorderMeters! < 1000) {
      borderText = 'எல்லைக்கு தூரம்: ${_lastBorderMeters!.toStringAsFixed(0)} மீ';
    } else {
      borderText = 'எல்லைக்கு தூரம்: ${(_lastBorderMeters! / 1000).toStringAsFixed(2)} கி.மீ';
    }

    // Drawer header values
    final box = Hive.box('fisherman_box');
    final user = (box.get('user') as Map?) ?? {};
    final fishermanName = (user['name'] ?? 'மீனவர்').toString();
    final boatNo = (user['boatRegNo'] ?? '—').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FB),
      appBar: AppBar(
        title: const Text('முதன்மை திரை'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Image.asset(
              'assets/images/app_logo.png',
              height: 38,
              errorBuilder: (_, __, ___) => const Icon(Icons.sailing),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0E54A7), Color(0xFF2E9EEA)]),
              ),
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.transparent),
                accountName: Text(fishermanName),           // from Hive
                accountEmail: Text('படகு எண்: $boatNo'),     // from Hive
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('மீனவர் சேர்க்க'),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).pushNamed('/register', arguments: {'mode': 'add'});
                setState(() {}); // refresh header
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('விவரங்களை திருத்து'),
              onTap: () async {
                Navigator.of(context).pop();
                final changed = await Navigator.of(context).pushNamed('/profile', arguments: user);
                if (changed == true) setState(() {});
              },
            ),
            const Divider(),

            // NEW: About the app (Tamil)
            AboutListTile(
              icon: const Icon(Icons.info_outline),
              child: const Text('இந்த செயலி பற்றி'),
              applicationName: 'Sea Siren Alert',
              applicationVersion: '1.0.0',
              applicationIcon: Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 6),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  height: 36,
                  errorBuilder: (_, __, ___) => const Icon(Icons.sailing),
                ),
              ),
              aboutBoxChildren: const [
                SizedBox(height: 12),
                Text(
                  'Sea Siren Alert என்பது தமிழ்நாடு மீனவர்களுக்கு எல்லை அருகாமை எச்சரிக்கைகள் '
                      '(3 கி.மீ / 1 கி.மீ / 500 மீ) முழுத்திரை நிறங்கள் மற்றும் ஒலியுடன் வழங்கும் '
                      'ஆஃப்லைன் முன்னுரிமை செயலி. GPS மூலம் செயல்பட்டு, கடற்கரை வரைபடங்களை '
                      'முன்கூட்டியே பதிவிறக்கம் செய்து இணையமின்றி கூட காண்பிக்க உதவுகிறது.',
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8),
                Text(
                  'அம்சங்கள்: எல்லை எச்சரிக்கை, ஆஃப்லைன் வரைபடம், வானிலை தகவல், SOS செய்தி.',
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8),
                Text(
                  'மறுப்பு: அதிகாரப்பூர்வ அறிவுறுத்தல்களே முதன்மை. இந்த செயலி உதவிக்காக மட்டுமே.',
                  textAlign: TextAlign.start,
                ),
              ],
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('வெளியேறு'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tagline
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'உங்கள் கடல் பயண பாதுகாப்பு துணை',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 14),

            // Weather stats
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _statChip(
                        icon: Icons.air,
                        tint: const Color(0xFF0E74C9),
                        titleTa: 'காற்று வேகம்',
                        value: '$windKts kts',
                        subtitle: windDir,
                      ),
                      const SizedBox(width: 12),
                      _statChip(
                        icon: Icons.waves,
                        tint: const Color(0xFF06A69E),
                        titleTa: 'அலை உயரம்',
                        value: '$tideM m',
                        subtitle: tideTrend,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick tiles with gradient background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE7F3FF), Color(0xFFEFFCFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _quickTile(
                        icon: Icons.my_location,
                        titleTa: 'நேரடி இடம்',
                        onTap: () => Navigator.of(context).pushNamed('/map'),
                        bg: const Color(0xFFEFF6FF),
                        fg: const Color(0xFF0E54A7),
                      ),
                      const SizedBox(width: 12),
                      _quickTile(
                        icon: Icons.cloud,
                        titleTa: 'வானிலை நிலை',
                        onTap: () => Navigator.of(context).pushNamed('/weather'),
                        bg: const Color(0xFFEFFCFB),
                        fg: const Color(0xFF06A69E),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _quickTile(
                        icon: Icons.notifications_active_outlined,
                        titleTa: '              சமீபத்திய                       .         எச்சரிக்கைகள்',
                        onTap: () => Navigator.of(context).pushNamed('/recent_alerts'),
                        bg: const Color(0xFFFFF8E6),
                        fg: const Color(0xFFB77900),
                      ),
                      const SizedBox(width: 12),
                      _quickTile(
                        icon: Icons.sms_outlined,
                        titleTa: 'SOS செய்தி',
                        onTap: () {
                          // Optional: open SOS flow
                        },
                        bg: const Color(0xFFFFEEF0),
                        fg: const Color(0xFFB3261E),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Offline download progress (if running)
            if (_downloading) ...[
              const Text('ஆஃப்லைன் வரைபடம் பதிவிறக்கம் நடைபெறுகிறது...', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              if (pct != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(value: pct),
                ),
              const SizedBox(height: 4),
              Text(
                _totalTiles == null ? 'தயார் ஆகிறது...' : '$_attemptedTiles / $_totalTiles டைல்கள்',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            // Live border distance card (above CTA)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0E54A7),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.social_distance, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('எல்லை தூரம்', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text(
                          borderText,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Start Journey CTA
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0E54A7), Color(0xFF2E9EEA)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: _downloading ? null : _openMapWithOffline,
                icon: const Icon(Icons.near_me, color: Colors.white),
                label: const Text('பயணம் தொடங்கு', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
