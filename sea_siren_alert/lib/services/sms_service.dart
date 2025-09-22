import 'package:hive/hive.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../models/log_model.dart';

class LogService {
  static final key = encrypt.Key.fromLength(32);
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  static Future<void> logEvent(String event, String data) async {
    try {
      final encryptedData = encrypter.encrypt(data, iv: iv).base64;
      final log = LogModel(
        timestamp: DateTime.now().toIso8601String(),
        event: event,
        encryptedData: encryptedData,
      );
      final box = Hive.box('logBox');
      await box.add(log);
    } catch (e) {
      print('Log error: $e');
    }
  }

  static Future<void> syncLogs() async {
    print('Syncing logs...');
  }
}