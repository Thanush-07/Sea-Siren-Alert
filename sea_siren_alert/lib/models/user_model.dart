import 'package:hive/hive.dart';

part 'user_model.g.dart';  // Run: flutter pub run build_runner build

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  @HiveField(2)
  String language;  // 'ta' for Tamil, 'en' for English

  UserModel({required this.name, required this.phone, required this.language});
}