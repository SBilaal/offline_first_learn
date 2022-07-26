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
        print(duration.inMilliseconds);
        print('Successful retry');
        return result;
      }
      if (result is Failure) {
        retries--;
        currentDuration *= 2;
        print(duration.inMilliseconds);
        print('failed retrying again...');
        retried = true;
      }
    }

    return result;
  }

  Future<void> runCommands() async {
    List<Command> commands = getAllCommands();
    if (commands.isNotEmpty && await networkInfo.isConnected) {
      for (var command in commands) {
        final receiver = keyToReceiver[command.receiver]!;
        receiver.data = command.data;
        print(receiver.data.customerName);

        late ApiResult<dynamic> result;

        result = await retry(() => receiver());

        if (result is Success) {
          _bookOrderStore.deleteCommand();
          print('Success');
        } else {
          command.status = UploadStatus.failed;
          print('Failure');
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
    final getOrders = DeleteOrdersReceiver();
    getOrders.data = orderId;
    return getOrders();
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
