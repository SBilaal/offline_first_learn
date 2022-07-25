import 'package:offline_first/data/remote_data_source.dart';
import 'package:offline_first/models/receiver.dart';

class ReceiverType {
  static const createOrder = "CreateOrder";
  static const updateOrder = "UpdateOrder";
}

final Map<String, Receiver> keyToReceiver = {
  ReceiverType.createOrder: PostOrderReceiver()
};
