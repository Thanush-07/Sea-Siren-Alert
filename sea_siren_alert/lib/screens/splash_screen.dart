import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'registration_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      try {
        var userBox = Hive.box('userBox');
        if (userBox.get('user') == null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegistrationScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      } catch (e) {
        print('Splash error: $e');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegistrationScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 100,
              errorBuilder: (_, __, ___) => const Text('SEA SIREN ALERT'),
            ),
            const Text('SEA SIREN ALERT', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}