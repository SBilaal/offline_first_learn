import 'package:hive_flutter/adapters.dart';
part 'bgd_task.g.dart';

@HiveType(typeId: 0)
class BgdTask {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String hexCode;
  @HiveField(2)
  final String id;

  BgdTask( {
    required this.id,
    required this.title,
    required this.hexCode,
  });
}
