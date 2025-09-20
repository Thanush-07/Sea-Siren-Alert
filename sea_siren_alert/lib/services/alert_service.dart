import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';

class AlertService {
  static final FlutterTts _tts = FlutterTts();
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    var userBox = Hive.box('userBox');
    var user = userBox.get('user');
    await _tts.setLanguage(user?.language == 'Tamil' ? 'ta-IN' : 'en-US');
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(const InitializationSettings(android: androidInit));
  }

  static Future<void> triggerGentleAlert() async {
    var userBox = Hive.box('userBox');
    var user = userBox.get('user');
    String message = user?.language == 'Tamil' ? 'எல்லைக்கு 5 கி.மீ' : '5km to border';
    await _notifications.show(
      0,
      'Alert',
      message,
      const NotificationDetails(android: AndroidNotificationDetails('alert_channel', 'Alerts', priority: Priority.low)),
    );
    await _tts.speak(message);
  }

  static Future<void> triggerUrgentAlert() async {
    var userBox = Hive.box('userBox');
    var user = userBox.get('user');
    String message = user?.language == 'Tamil' ? 'எல்லைக்கு 2 கி.மீ - பயணத்தை தவிர்க்கவும்' : '2km to border - Turn back';
    await _notifications.show(
      1,
      'Urgent Alert',
      message,
      const NotificationDetails(android: AndroidNotificationDetails('alert_channel', 'Alerts', priority: Priority.high)),
    );
    await _tts.speak(message);
  }

  static Future<void> triggerCriticalAlert(BuildContext context) async {
    var userBox = Hive.box('userBox');
    var user = userBox.get('user');
    String message = user?.language == 'Tamil' ? 'ஆபத்து: எல்லைக்கு 500 மீ!' : 'Danger: 500m to border!';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.red,
        title: Text(message),
        content: Text(user?.language == 'Tamil' ? 'உடனே திரும்பவும்!' : 'Turn back immediately!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    await _notifications.show(
      2,
      'Critical Alert',
      message,
      const NotificationDetails(android: AndroidNotificationDetails('alert_channel', 'Alerts', priority: Priority.max)),
    );
    await _tts.speak(message);
  }
}