// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bgd_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BgdTaskAdapter extends TypeAdapter<BgdTask> {
  @override
  final int typeId = 0;

  @override
  BgdTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BgdTask(
      id: fields[2] as String,
      title: fields[0] as String,
      hexCode: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BgdTask obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.hexCode)
      ..writeByte(2)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BgdTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
