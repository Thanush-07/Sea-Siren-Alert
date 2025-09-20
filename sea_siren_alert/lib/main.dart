import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import './models/user_model.dart';
import './screens/registration_screen.dart';
import './screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      var userBox = Hive.box('userBox');
      if (userBox.get('user') == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegistrationScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/logo.png'),  // Add placeholder if missing
      ),
    );
  }
}