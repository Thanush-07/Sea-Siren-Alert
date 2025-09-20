// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LogModelAdapter extends TypeAdapter<LogModel> {
  @override
  final int typeId = 1;

  @override
  LogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LogModel(
      timestamp: fields[0] as String,
      event: fields[1] as String,
      encryptedData: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LogModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.event)
      ..writeByte(2)
      ..write(obj.encryptedData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
