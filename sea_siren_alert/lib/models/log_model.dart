import 'package:hive/hive.dart';

part 'log_model.g.dart';

@HiveType(typeId: 1)
class LogModel extends HiveObject {
  @HiveField(0)
  String timestamp;

  @HiveField(1)
  String event;

  @HiveField(2)
  String encryptedData;

  LogModel({required this.timestamp, required this.event, required this.encryptedData});
}