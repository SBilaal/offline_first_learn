import 'package:offline_first/api/api_result.dart';

abstract class Receiver {
  Future<ApiResult> call();
  dynamic data;
}
