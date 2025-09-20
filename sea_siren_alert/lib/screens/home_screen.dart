import 'package:flutter/material.dart';
import '../services/alert_service.dart';  // Add this file later

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AlertService.init();  // Initialize alerts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sea Siren Alert - முகப்பு')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('உங்கள் படகு பாதுகாப்பாக உள்ளது / Your boat is safe.'),
            ElevatedButton(
              onPressed: () {
                // Simulate alert for testing
                AlertService.triggerGentleAlert();
              },
              child: const Text('Test Alert'),
            ),
          ],
        ),
      ),
    );
  }
}