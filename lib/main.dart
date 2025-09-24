import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import './src/screens/registration.dart';
import './src/screens/home.dart';
import './utils/constants.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(kHiveBox);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
      debugShowCheckedModeBanner: false,
      initialRoute: '/register', // 👈 Start with home.dart
      getPages: [
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/register', page: () => RegistrationPage()),
      ],
    );
  }
}
