import 'package:hive_flutter/adapters.dart';

part 'command.g.dart';

@HiveType(typeId: 1)
class Command<T> {
  Command({required this.receiver, required this.createdAt, required this.data, required this.id});

  @HiveField(0)
  DateTime createdAt;
  @HiveField(1)
  T data;
  @HiveField(2)
  int retries = 0;
  @HiveField(3)
  UploadStatus status = UploadStatus.pending;
  @HiveField(4)
  String id;
  @HiveField(5)
  String receiver;
}

@HiveType(typeId: 2)
enum UploadStatus {
  @HiveField(0)
  uploaded,
  @HiveField(1)
  pending,
  @HiveField(2)
  uploading,
  @HiveField(3)
  failed,
  @HiveField(4)
  cancelled,
}
