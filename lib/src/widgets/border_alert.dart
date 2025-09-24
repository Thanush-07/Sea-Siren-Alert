import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

enum BorderAlertLevel { km3, km1, m500 }

class BorderAlert {
  static bool _showing = false;
  static final AudioPlayer _player = AudioPlayer();

  static Color color(BorderAlertLevel level) {
    switch (level) {
      case BorderAlertLevel.km3: return Colors.amber[800]!;
      case BorderAlertLevel.km1: return Colors.deepOrange;
      case BorderAlertLevel.m500: return Colors.red;
    }
  }

  static String message(BorderAlertLevel level) {
    switch (level) {
      case BorderAlertLevel.km3:
        return 'எச்சரிக்கை: எல்லைக்கு 3 கி.மீ அருகில் உள்ளீர்கள்.';
      case BorderAlertLevel.km1:
        return 'கவனம்: எல்லைக்கு 1 கி.மீ தான் உள்ளது.';
      case BorderAlertLevel.m500:
        return 'மிகவும் அருகில்: 500 மீ மட்டுமே உள்ளது. உடனே திரும்பவும்.';
    }
  }

  // IMPORTANT: AssetSource should be relative to the assets/ prefix declared in pubspec
  static String tone(BorderAlertLevel level) {
    switch (level) {
      case BorderAlertLevel.km3: return 'assets/audio/alert_1km.mp3';
      case BorderAlertLevel.km1: return 'assets/audio/alert_3km.wav';
      case BorderAlertLevel.m500: return 'assets/audio/alert_500m.mp3';
    }
  }

  static Future<void> show(BuildContext context, BorderAlertLevel level) async {
    if (_showing) return;
    _showing = true;

    // Capture navigator before any await to avoid using context across async gaps
    final nav = Navigator.of(context);

    try {
      // Play tone (no UI context needed)
      await _player.stop();
      await _player.play(AssetSource(tone(level)));
    } catch (_) {}

    // Guard: context could be unmounted while awaiting
    if (!context.mounted) {
      _showing = false;
      return;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'BorderAlert',
      pageBuilder: (ctx, _, __) {
        return Material(
          color: color(level),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      level == BorderAlertLevel.m500
                          ? Icons.emergency
                          : Icons.warning_amber_rounded,
                      size: 88,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message(level),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                      ),
                      onPressed: () async {
                        try { await _player.stop(); } catch (_) {}
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                        }
                      },
                      child: const Text('சரி (OK)'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    _showing = false;
  }
}
