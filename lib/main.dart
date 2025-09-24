import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

// Screens
import 'src/screens/splash.dart';
import 'src/screens/login.dart';
import 'src/screens/registration.dart';
import 'src/screens/home.dart';
import 'src/screens/map.dart';
import 'src/screens/weather.dart';
import 'src/screens/profile.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('fisherman_box');

  try {
    await FMTCObjectBoxBackend().initialise();
    await FMTCStore('mapStore').manage.create();
  } catch (e) {
    debugPrint('FMTC init error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sea Siren Alert',
      locale: const Locale('ta'),
      supportedLocales: const [Locale('ta'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/home': (context) => const HomeScreen(),
        '/map': (context) => const OfflineMapScreen(),
        '/weather': (context) => const WeatherAlertScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
