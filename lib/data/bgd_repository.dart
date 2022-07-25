import 'package:offline_first/network_checker.dart';

import '../models/bgd_task.dart';
import 'bgd_task_store.dart';

class BgdRepository {
  final bgdTaskStore = BgdTaskStore();
  final networkChecker = NetworkChecker();

  Future<List<BgdTask>> getAllTasksA() => bgdTaskStore.getAllTasksA();
  Future<List<BgdTask>> getAllTasksB() => bgdTaskStore.getAllTasksB();

  Future<void> queueTask(BgdTask task) async {
    await bgdTaskStore.addTaskA(task);
    
  }

  Future<void> postAndDequeueTask() async {
    if (await networkChecker.isConnected && bgdTaskStore.isANotEmpty) {
      var tasks = await bgdTaskStore.getAllTasksA();
      for (var task in tasks) {
        await Future.delayed(
        const Duration(seconds: 2),
        () async {
          await bgdTaskStore.addTaskB(task);
          await bgdTaskStore.deleteTaskA(task);
        },
      );
      }
    }
  }

  Future<void> clearAll() async => await bgdTaskStore.clearAll();


}
