import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:offline_first/models/command.dart';

class BookOrderStore {
  final _orderBox = Hive.box<Command>('order');

  ValueListenable<Box<dynamic>> get orderStoreListenable =>
      _orderBox.listenable();

  List<Command> getAllCommands() {
    if (_orderBox.isEmpty) return [];
    return _orderBox.values.toList();
  }

  Future<void> addCommand(Command command) async {
    await _orderBox.add(command);
  }

  Future<Command?> getCommand() async {
    if (_orderBox.isNotEmpty) {
      final commmand = _orderBox.getAt(0);
      return Future.value(commmand);
    }
    return null;
  }

  Future<void> deleteCommand() async {
    if (_orderBox.isNotEmpty) await _orderBox.deleteAt(0);
  }

  Future<void> deleteAllCommands() async {
    await _orderBox.clear();
  }
}
