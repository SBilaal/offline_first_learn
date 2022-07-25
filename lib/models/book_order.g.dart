// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookOrderAdapter extends TypeAdapter<_$_BookOrder> {
  @override
  final int typeId = 3;

  @override
  _$_BookOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$_BookOrder(
      bookId: fields[0] as int,
      customerName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, _$_BookOrder obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.bookId)
      ..writeByte(1)
      ..write(obj.customerName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BookOrder _$$_BookOrderFromJson(Map<String, dynamic> json) => _$_BookOrder(
      bookId: json['bookId'] as int,
      customerName: json['customerName'] as String,
    );

Map<String, dynamic> _$$_BookOrderToJson(_$_BookOrder instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'customerName': instance.customerName,
    };
