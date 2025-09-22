import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import '../constants.dart';

class SmsService {
  static bool _isInitialized = false;

  static Future<void> init() async {
    try {
      // Initialize SMS service
      _isInitialized = true;
      print('SMS Service initialized');
    } catch (e) {
      print('SMS Service initialization error: $e');
    }
  }

  static Future<void> sendToCoastGuard(BuildContext context, LatLng position) async {
    try {
      if (!_isInitialized) {
        await init();
      }

      final message = 'EMERGENCY: Fishing vessel in distress at coordinates: '
          'Latitude ${position.latitude.toStringAsFixed(6)}, '
          'Longitude ${position.longitude.toStringAsFixed(6)}. '
          'Immediate assistance required.';

      // Queue the SMS for sending
      final box = Hive.box('smsQueue');
      await box.add({
        'number': coastGuardNumber,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'sent': false,
      });

      // Show confirmation to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency SMS queued for Coast Guard'),
            backgroundColor: Colors.red,
          ),
        );
      }

      print('Emergency SMS queued: $message');
    } catch (e) {
      print('SMS sending error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send emergency SMS'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> processSmsQueue() async {
    try {
      final box = Hive.box('smsQueue');
      final unsentMessages = box.values.where((msg) => !msg['sent']).toList();
      
      for (var message in unsentMessages) {
        // In a real implementation, you would use a package like telephony
        // to actually send SMS messages
        print('Sending SMS to ${message['number']}: ${message['message']}');
        
        // Mark as sent
        final index = box.values.toList().indexOf(message);
        message['sent'] = true;
        await box.putAt(index, message);
      }
    } catch (e) {
      print('SMS queue processing error: $e');
    }
  }
}