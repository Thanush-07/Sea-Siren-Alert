import 'package:flutter/material.dart';

class TamilWeatherAlertsPage extends StatelessWidget {
  const TamilWeatherAlertsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alerts = [
      {
        'type': 'புயல் எச்சரிக்கை',
        'description':
        'பங்கால் வளைகுடாவில் உருவான "மிகா" புயல் கடலோர பகுதிகளில் தீவிரமான காற்று மற்றும் பெருவெள்ளத்தைக் ஏற்படுத்தும். மீனவர்கள் கடலில் செல்ல வேண்டாம்.',
        'icon': Icons.cyclone,
        'color': Colors.red[100],
      },
      {
        'type': 'கடல் சீற்ற எச்சரிக்கை',
        'description':
        'வலுவான காற்று காரணமாக கடல் சீற்றமாக இருக்கும். சிறிய படகுகளை பயன்படுத்தும் மீனவர்கள் கடலில் செல்லத் தவிர்க்கவும்.',
        'icon': Icons.waves,
        'color': Colors.orange[100],
      },
      {
        'type': 'வெள்ள அபாய எச்சரிக்கை',
        'description':
        'தென் மாவட்டங்களில் கனமழை காரணமாக நதிகள் மற்றும் கால்வாய்களில் வெள்ள அபாயம் உள்ளது. மத்தியகடலுக்குள் செல்ல வேண்டாம்.',
        'icon': Icons.water_damage_outlined,
        'color': Colors.blue[100],
      },
      {
        'type': 'உயர் அலை எச்சரிக்கை',
        'description':
        'இன்று மாலையில் கடலில் 2-3 மீட்டர் உயரத்தில் அலைகள் எழும். மீனவர்கள் பாதுகாப்பாக இருக்க வேண்டிய அவசியம் உள்ளது.',
        'icon': Icons.trending_up,
        'color': Colors.teal[100],
      },
      {
        'type': 'கடல் திசை மாற்றம்',
        'description':
        'வடகிழக்கு பருவமழை காரணமாக கடல் திசை மாறியுள்ளதால், சீரான மீன்பிடி சாத்தியம் குறைவாக உள்ளது.',
        'icon': Icons.explore_outlined,
        'color': Colors.purple[100],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'சமீபத்திய எச்சரிக்கைகள்',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFF8E6),
        foregroundColor: const Color(0xFFB77900),
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: alerts.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Card(
            color: alert['color'] as Color?,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                alert['icon'] as IconData,
                size: 40,
                color: Colors.black87,
              ),
              title: Text(
                alert['type'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'NotoSansTamil',
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  alert['description'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'NotoSansTamil',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
