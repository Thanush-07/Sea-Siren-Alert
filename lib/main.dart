import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:audioplayers/audioplayers.dart';

// Screens
import 'src/screens/splash.dart';
import 'src/screens/login.dart';
import 'src/screens/registration.dart';
import 'src/screens/home.dart';
import 'src/screens/map.dart';
import 'src/screens/weather.dart';
import 'src/screens/profile.dart';
import 'src/widgets/recent_alerts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local storage (Hive)
  await Hive.initFlutter();
  await Hive.openBox('fisherman_box');

  // FMTC (offline tiles) with ObjectBox backend
  try {
    await FMTCObjectBoxBackend().initialise();
    await FMTCStore('mapStore').manage.create();
  } catch (e) {
    debugPrint('FMTC init error: $e');
  }

  // Audio context for alert tones (audioplayers 6.x)
  // Use non-const constructors to avoid "constructor isn't const" errors across versions.
  await AudioPlayer.global.setAudioContext(
    AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
      android: AudioContextAndroid(
        usageType: AndroidUsageType.alarm,
        contentType: AndroidContentType.sonification,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        isSpeakerphoneOn: true,
        stayAwake: false,
      ),
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sea Siren Alert',
      debugShowCheckedModeBanner: false,

      // Tamil-first app; English fallback
      locale: const Locale('ta'),
      supportedLocales: const [
        Locale('ta'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Initial route (Splash)
      home: const SplashScreen(),

      // Named routes
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/home': (context) => const HomeScreen(),
        '/map': (context) => const OfflineMapScreen(),
        '/weather': (context) => const WeatherAlertScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/recent_alerts': (context) => const TamilWeatherAlertsPage(),
      },
    );
  }
}
