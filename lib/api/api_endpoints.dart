class ApiEndpoints {
  ApiEndpoints._();

  static const String _api = 'https://simple-books-api.glitch.me/';

  static String get orders {
    return '${_api}orders';
  }

}
