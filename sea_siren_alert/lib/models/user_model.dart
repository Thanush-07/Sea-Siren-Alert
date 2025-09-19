import 'package:hive/hive.dart';

part 'user_model.g.dart';  // Generated file goes here

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  @HiveField(2)
  String language;

  UserModel({required this.name, required this.phone, required this.language});
}