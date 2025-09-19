import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';

class AlertService {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> init() async {
    var userBox = Hive.box('userBox');
    var user = userBox.get('user');
    await _tts.setLanguage(user?.language == 'Tamil' ? 'ta-IN' : 'en-US');
  }

  static void triggerGentleAlert() {
    _tts.speak('எல்லைக்கு 5 கி.மீ / 5km to border');
  }
}