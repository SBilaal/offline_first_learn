import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/bgd_task.dart';

class BgdTaskStore {
  final _bgdTaskStoreA = Hive.box('tasks_a');
  final _bgdTaskStoreB = Hive.box('tasks_b');

  ValueListenable<Box<dynamic>> get bgdStoreListenable => _bgdTaskStoreA.listenable();

  bool get isANotEmpty {
    return _bgdTaskStoreA.isNotEmpty;
  }

  // Task A
  Future<List<BgdTask>> getAllTasksA() async {
    if (_bgdTaskStoreA.isEmpty) {
      return [];
    }
    return List<BgdTask>.from(_bgdTaskStoreA.values);
  }

  Future<void> addTaskA(BgdTask task) async {
    await _bgdTaskStoreA.put(task.id, task);
  }

  Future<void> deleteTaskA(BgdTask task) async {
    await _bgdTaskStoreA.delete(task.id);
  }

  // Task B
  Future<List<BgdTask>> getAllTasksB() async {
    if (_bgdTaskStoreB.isEmpty) {
      return [];
    }
    return List<BgdTask>.from(_bgdTaskStoreB.values);
  }

  Future<void> addTaskB(BgdTask task) async {
    await _bgdTaskStoreB.put(task.id, task);
  }

  Future<void> deleteTaskB(BgdTask task) async {
    await _bgdTaskStoreB.delete(task.id);
  }

  Future<void> clearAll() async {
    await _bgdTaskStoreA.clear();
    await _bgdTaskStoreB.clear();
  }
}

// class Result {}

// class Success extends Result {}

// class Failure extends Result {}
