import 'package:dio/dio.dart';
import 'package:offline_first/api/api_endpoints.dart';
import 'package:offline_first/api/api_result.dart';
import 'package:offline_first/models/book_order.dart';
import 'package:offline_first/models/order.dart';
import 'package:offline_first/models/receiver.dart';

import '../api/dio_client.dart';
import '../api/network_exceptions.dart';

final dioClient = DioClient(Dio());
const token =
    '38b0406596fe3909971f1d63f4889cfe42e09cfeba848a72ce4f9f5a57303a37';

class PostOrderReceiver extends Receiver {
  @override
  Future<ApiResult> call() async {
    try {
      var bookOrder = data as BookOrder;
      final response = await dioClient.post(ApiEndpoints.orders,
          data: bookOrder.toJson(),
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return ApiResult.success(data: response);
    } catch (e) {
      print(e);
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }
}

class GetOrdersReceiver extends Receiver {
  @override
  Future<ApiResult<List<Order>>> call() async {
    try {
      final response = await dioClient.get(ApiEndpoints.orders,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return ApiResult.success(data: _parseOrders(response));
    } catch (e, stackrace) {
      print(stackrace);
      print(e);
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  List<Order> _parseOrders(List<dynamic> responseBody) {
    if (responseBody.isEmpty) {
      return [];
    }
    return responseBody.map<Order>((json) => Order.fromJson(json)).toList();
  }
}

class DeleteOrdersReceiver extends Receiver {
  @override
  Future<ApiResult> call() async {
    var orderId = data as String;
    try {
      final response = await dioClient.delete(
        ApiEndpoints.orders + "/$orderId",
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return ApiResult.success(data: response);
    } catch (e, stackrace) {
      print(stackrace);
      print(e);
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }
}
