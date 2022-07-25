import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/adapters.dart';

part 'book_order.freezed.dart';
part 'book_order.g.dart';

@freezed
class BookOrder with _$BookOrder {
  @HiveType(typeId: 3, adapterName: 'BookOrderAdapter')
  factory BookOrder({
    @HiveField(0) required int bookId,
    @HiveField(1) required String customerName,
  }) = _BookOrder;

  factory BookOrder.fromJson(Map<String, dynamic> json) =>
      _$BookOrderFromJson(json);
}
