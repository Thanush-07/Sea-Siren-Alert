import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _routeAfterDelay() async {
    final box = Hive.box('fisherman_box');
    final bool isLoggedIn = box.get('isLoggedIn') == true;

    // Branded pause
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    if (isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _routeAfterDelay();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/app_logo.png', width: 350, height: 250),
            const SizedBox(height: 12),
            const Text('Sea Siren Alert', style: TextStyle(fontSize: 25)),
          ],
        ),
      ),
    );
  }
}
