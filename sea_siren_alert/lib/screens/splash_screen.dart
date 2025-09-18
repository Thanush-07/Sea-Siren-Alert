import 'package:flutter/material.dart';
import 'package:sea_siren_alert/screens/registration_screen.dart';
import 'package:sea_siren_alert/screens/home_screen.dart';
import 'package:sea_siren_alert/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      final user = StorageService.getUser();
      if (user == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegistrationScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(asset: 'assets/images/logo.png'),  // Your logo
      ),
    );
  }
}