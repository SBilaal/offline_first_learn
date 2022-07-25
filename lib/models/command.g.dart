// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommandAdapter<T> extends TypeAdapter<Command<T>> {
  CommandAdapter({required this.typeId});

  @override
  final int typeId;

  @override
  Command<T> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Command(
      receiver: fields[5] as String,
      createdAt: fields[0] as DateTime,
      data: fields[1] as T,
      id: fields[4] as String,
    )
      ..retries = fields[2] as int
      ..status = fields[3] as UploadStatus;
  }

  @override
  void write(BinaryWriter writer, Command obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.createdAt)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.retries)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.receiver);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommandAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UploadStatusAdapter extends TypeAdapter<UploadStatus> {
  @override
  final int typeId = 2;

  @override
  UploadStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UploadStatus.uploaded;
      case 1:
        return UploadStatus.pending;
      case 2:
        return UploadStatus.uploading;
      case 3:
        return UploadStatus.failed;
      case 4:
        return UploadStatus.cancelled;
      default:
        return UploadStatus.uploaded;
    }
  }

  @override
  void write(BinaryWriter writer, UploadStatus obj) {
    switch (obj) {
      case UploadStatus.uploaded:
        writer.writeByte(0);
        break;
      case UploadStatus.pending:
        writer.writeByte(1);
        break;
      case UploadStatus.uploading:
        writer.writeByte(2);
        break;
      case UploadStatus.failed:
        writer.writeByte(3);
        break;
      case UploadStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
