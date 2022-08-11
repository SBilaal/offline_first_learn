import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:offline_first/models/command.dart';

class BookOrderStore {
  // final _orderBox = Hive.box<Command>('order');
  final _orderBox = Hive.box('queue_order');
  final key = "orders";

  ValueListenable<Box<dynamic>> get orderStoreListenable =>
      _orderBox.listenable();

  bool get isEmpty {
    return _orderBox.isEmpty || getAllCommands().isEmpty;
  }

  List<Command> getAllCommands() {
    if (_orderBox.isEmpty) return [];
    List list = _orderBox.get(key, defaultValue: [])!;
    return list.cast<Command>();
    // return _orderBox.values.toList();
  }

  Future<void> flush() async {
   await _orderBox.flush();
  }

  Future<void> addCommand(Command command) async {
    // await _orderBox.add(command);
    List<Command> list = getAllCommands();
    list.add(command);
    await _orderBox.put(key, list);
  }

  Future<Command> popCommand() async {
    List<Command> list = getAllCommands();
    Command command = list[0];
    list.removeAt(0);
    _orderBox.put(key, list);
    return command;
  }

  Future<void> enqueueCommand(Command command) async {
    List<Command> list = getAllCommands();
    list.insert(0, command);
    _orderBox.put(key, list);
  }

  // Future<Command?> getCommand() async {
  //   if (_orderBox.isNotEmpty) {
  //     // final commmand = _orderBox.getAt(0);
  //     final commmand = _orderBox.get(0)![0];
  //     return Future.value(commmand);
  //   }
  //   return null;
  // }

  // Future<void> deleteCommand() async {
  //   if (_orderBox.isNotEmpty) await _orderBox.deleteAt(0);
  // }

  Future<void> deleteAllCommands() async {
    await _orderBox.clear();
  }
}
