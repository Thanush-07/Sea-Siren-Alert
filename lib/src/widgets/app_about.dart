import 'package:flutter/material.dart';

class AppAbout {
  static Future<void> show(BuildContext context) async {
    showAboutDialog(
      context: context,
      applicationName: 'Sea Siren Alert',
      applicationVersion: '1.0.0',
      applicationIcon: SizedBox(
        width: 48,
        height: 48,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/app_logo.png',
            errorBuilder: (_, __, ___) => const Icon(Icons.sailing, size: 48),
            fit: BoxFit.contain,
          ),
        ),
      ),
      children: const [
        SizedBox(height: 12),
        // Tamil description
        Text(
          'Sea Siren Alert என்பது தமிழ்நாடு மீனவர்களின் பாதுகாப்புக்காக உருவாக்கப்பட்ட '
              'ஆஃப்லைன் முன்னுரிமை செயலி. எல்லை அருகாமை எச்சரிக்கைகள் (3 கி.மீ / 1 கி.மீ / 500 மீ) '
              'தெளிவான நிறத் திரை மற்றும் ஒலி மூலம் தெரிவிக்கப்படும். இணையமின்றியும் GPS மூலம் செயல்படும்.',
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 8),
        Text(
          'முக்கிய அம்சங்கள்:\n'
              '• எல்லை எச்சரிக்கை: 3 கி.மீ (மஞ்சள்), 1 கி.மீ (ஆரஞ்சு), 500 மீ (சிகப்பு) முழுத்திரை எச்சரிக்கை.\n'
              '• ஒலித் தகவல்கள்: நிலைதோறும் தனித்தனி அலாரம்/வொய்ஸ் டோன்.\n'
              '• ஆஃப்லைன் வரைபடம்: கடற்கரை பகுதிகளை முன்கூட்டியே பதிவிறக்கம் செய்து கடலில் தரம் குறையாமல் காண்பிப்பு.\n'
              '• Android SOS: 20 மீ எல்லை அருகில், 30 வினாடிகளில் பதில் இல்லை எனில் காவல்துறைக்கு SMS (நிலவரம் + வரைபட இணைப்பு). '
              'iOS-ல் SMS composer மட்டும் திறக்கும்.\n'
              '• வானிலை/அந்தர்கல தகவல்கள்: எதிர்பார்க்கப்படும் கடல் நிலை எச்சரிக்கைகள் (விரிவாக்கக்கூடியது).',
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 8),
        Text(
          'மறுப்பு (Disclaimer): இந்த செயலி தகவல்களை உதவிக்காக மட்டுமே வழங்குகிறது. '
              'அதிகாரப்பூர்வ வழிகாட்டுதல்களை, கடலோர காவல்துறை/அரசுத் துறைகளின் அறிவுறுத்தல்களை '
              'எப்போதும் முன்னுரிமை தாருங்கள்.',
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
