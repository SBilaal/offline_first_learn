import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_first/api/api_result.dart';
import 'package:offline_first/api/network_checker.dart';
import 'package:offline_first/data/remote_data_source.dart';
import 'package:offline_first/models/book_order.dart';
import 'package:offline_first/models/order.dart';
import 'package:offline_first/models/receiver_type.dart';
import 'package:uuid/uuid.dart';

import '../models/command.dart';
import 'book_order_store.dart';

const uuid = Uuid();
int count = 0;

class BookOrderRepo {
  final _bookOrderStore = BookOrderStore();
  final networkInfo = NetworkInfo();
  Future<void> storeCommand<T>(
      {T? data, String? receiverType, Command? failedCommand}) async {
    assert((data != null && receiverType != null) || failedCommand != null);
    await _bookOrderStore.addCommand(failedCommand ??
        Command<T>(
          receiver: receiverType!,
          createdAt: DateTime.now(),
          data: data!,
          id: uuid.v1(),
        ));
  }

  List<Command> getAllCommands() {
    print("All Commands" + _bookOrderStore.getAllCommands().toString());
    return _bookOrderStore.getAllCommands();
  }

  Future<ApiResult> retry(Future<ApiResult> Function() run,
      {int retries = 8}) async {
    bool retried = false;
    Duration currentDuration = const Duration(milliseconds: 200);
    const Duration initialDuration = Duration.zero;

    late ApiResult result;

    while (retries > 0) {
      var duration = retried ? currentDuration : initialDuration;
      await Future.delayed(duration, () async {
        result = await run();
      });
      if (result is Success) {
        return result;
      }
      if (result is Failure) {
        retries--;
        currentDuration *= 2;
        retried = true;
      }
    }

    return result;
  }

  Future<void> runCommands() async {
    List<Command> commands = getAllCommands();
    if (commands.isNotEmpty && await networkInfo.isConnected) {
      count++;
      print("count in runCommand: $count");
      while (commands.isNotEmpty) {
        final commandx = await _bookOrderStore.popCommand();
        final receiver = keyToReceiver[commandx.receiver]!;
        receiver.data = commandx.data;
        print(receiver.data.customerName);

        late ApiResult<dynamic> result;

        result = await retry(() => receiver());

        if (result is Failure) {
          _bookOrderStore.enqueueCommand(commandx);
          commandx.status = UploadStatus.failed;
          break;
        }
      }
    }
  }

  Future<ApiResult<List<Order>>> getOrders() async {
    final getOrders = GetOrdersReceiver();
    return getOrders();
  }

  Future<ApiResult> deleteOrders(String orderId) async {
    final deleteOrders = DeleteOrdersReceiver();
    deleteOrders.data = orderId;
    return deleteOrders();
  }
}

Future<void> setupHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(CommandAdapter<BookOrder>(typeId: 1));
  Hive.registerAdapter(UploadStatusAdapter());
  Hive.registerAdapter(BookOrderAdapter());

  await Hive.openBox<Command>('order');
}

// void main() async {
//   await setupHive();

//   final repo = BookOrderRepo();
//   repo.getAllCommands().forEach(print);
//   final result = await repo.getOrders();

//   result.when(success: (data) {
//     for (var order in data) {
//       print(order.customerName);
//     }
//   }, failure: (error) {
//     print(error);
//   });
//   repo.storeCommand<BookOrder>(
//     BookOrder(
//         bookId: Random().nextInt(5),
//         customerName: 'Bilaal ${Random().nextInt(78)} '),
//     ReceiverType.createOrder,
//   );
//   repo.runCommands();
// }
