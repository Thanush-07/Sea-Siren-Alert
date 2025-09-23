import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'map.dart';
import 'weather.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('முதன்மை திரை')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('கூகுள் வரைபடம்'),
              onPressed: () => Get.to(() => OfflineMapScreen()),
            ),
            ElevatedButton(
              child: const Text('வானிலை மற்றும் எச்சரிக்கைகள்'),
              onPressed: () => Get.to(() => WeatherAlertScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
