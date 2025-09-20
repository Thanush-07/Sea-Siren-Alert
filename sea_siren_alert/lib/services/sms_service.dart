import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import '../constants.dart';
import 'log_service.dart';

class SmsService {
  static final Telephony _telephony = Telephony.instance;

  static Future<void> init() async {
    try {
      bool? permissionsGranted = await _telephony.requestSmsPermissions;
      if (permissionsGranted != true) {
        print('SMS permission denied');
      }
    } catch (e) {
      print('SMS init error: $e');
    }
  }

  static Future<void> sendToCoastGuard(BuildContext context, LatLng position) async {
    var userBox = Hive.box('userBox');
    var user = userBox.get('user');
    if (user == null) return;

    String message = 'Boat [${user.phone}] crossing IMBL at [${position.latitude}, ${position.longitude}]. Help!';
    bool? consent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send SOS to Coast Guard?'),
        content: Text('Message: $message'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (consent == true) {
      try {
        await _telephony.sendSms(
          to: coastGuardNumber,
          message: message,
          statusListener: (SendStatus status) {
            print('SMS Status: $status');
            LogService.logEvent('SMS Sent', 'To: $coastGuardNumber, Message: $message');
          },
        );
      } catch (e) {
        print('SMS failed: $e');
        var queueBox = Hive.box('smsQueue');
        await queueBox.add({'to': coastGuardNumber, 'message': message});
        LogService.logEvent('SMS Queued', 'To: $coastGuardNumber, Message: $message');
      }
    }
  }

  static Future<void> retryQueuedSms() async {
    var queueBox = Hive.box('smsQueue');
    bool? isCapable = await _telephony.isSmsCapable;
    if (isCapable == true) {
      for (var sms in queueBox.values.toList()) {
        try {
          await _telephony.sendSms(to: sms['to'], message: sms['message']);
          await queueBox.delete(sms.key);
          LogService.logEvent('SMS Retried', 'To: ${sms['to']}, Message: ${sms['message']}');
        } catch (e) {
          print('Retry failed: $e');
        }
      }
    }
  }
}