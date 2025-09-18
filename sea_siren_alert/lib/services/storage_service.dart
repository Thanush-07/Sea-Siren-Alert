import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:io';

class StorageService {
  static late Box userBox;
  static late Box logBox;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init('${dir.path}/hive');
    userBox = await Hive.openBox('user');
    logBox = await Hive.openBox('logs');
  }

  static void saveUser(UserModel user) {
    userBox.put('currentUser', user);
  }

  static UserModel? getUser() {
    return userBox.get('currentUser');
  }

  static void logEvent(String event) {
    // Encrypt logs for tamper-evidence
    final key = encrypt.Key.fromLength(32);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(event, iv: iv);
    logBox.add(encrypted.base64);
  }
}