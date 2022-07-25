// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'book_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BookOrder _$BookOrderFromJson(Map<String, dynamic> json) {
  return _BookOrder.fromJson(json);
}

/// @nodoc
mixin _$BookOrder {
  @HiveField(0)
  int get bookId => throw _privateConstructorUsedError;
  @HiveField(1)
  String get customerName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookOrderCopyWith<BookOrder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookOrderCopyWith<$Res> {
  factory $BookOrderCopyWith(BookOrder value, $Res Function(BookOrder) then) =
      _$BookOrderCopyWithImpl<$Res>;
  $Res call({@HiveField(0) int bookId, @HiveField(1) String customerName});
}

/// @nodoc
class _$BookOrderCopyWithImpl<$Res> implements $BookOrderCopyWith<$Res> {
  _$BookOrderCopyWithImpl(this._value, this._then);

  final BookOrder _value;
  // ignore: unused_field
  final $Res Function(BookOrder) _then;

  @override
  $Res call({
    Object? bookId = freezed,
    Object? customerName = freezed,
  }) {
    return _then(_value.copyWith(
      bookId: bookId == freezed
          ? _value.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      customerName: customerName == freezed
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_BookOrderCopyWith<$Res> implements $BookOrderCopyWith<$Res> {
  factory _$$_BookOrderCopyWith(
          _$_BookOrder value, $Res Function(_$_BookOrder) then) =
      __$$_BookOrderCopyWithImpl<$Res>;
  @override
  $Res call({@HiveField(0) int bookId, @HiveField(1) String customerName});
}

/// @nodoc
class __$$_BookOrderCopyWithImpl<$Res> extends _$BookOrderCopyWithImpl<$Res>
    implements _$$_BookOrderCopyWith<$Res> {
  __$$_BookOrderCopyWithImpl(
      _$_BookOrder _value, $Res Function(_$_BookOrder) _then)
      : super(_value, (v) => _then(v as _$_BookOrder));

  @override
  _$_BookOrder get _value => super._value as _$_BookOrder;

  @override
  $Res call({
    Object? bookId = freezed,
    Object? customerName = freezed,
  }) {
    return _then(_$_BookOrder(
      bookId: bookId == freezed
          ? _value.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      customerName: customerName == freezed
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 3, adapterName: 'BookOrderAdapter')
class _$_BookOrder with DiagnosticableTreeMixin implements _BookOrder {
  _$_BookOrder(
      {@HiveField(0) required this.bookId,
      @HiveField(1) required this.customerName});

  factory _$_BookOrder.fromJson(Map<String, dynamic> json) =>
      _$$_BookOrderFromJson(json);

  @override
  @HiveField(0)
  final int bookId;
  @override
  @HiveField(1)
  final String customerName;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BookOrder(bookId: $bookId, customerName: $customerName)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'BookOrder'))
      ..add(DiagnosticsProperty('bookId', bookId))
      ..add(DiagnosticsProperty('customerName', customerName));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BookOrder &&
            const DeepCollectionEquality().equals(other.bookId, bookId) &&
            const DeepCollectionEquality()
                .equals(other.customerName, customerName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(bookId),
      const DeepCollectionEquality().hash(customerName));

  @JsonKey(ignore: true)
  @override
  _$$_BookOrderCopyWith<_$_BookOrder> get copyWith =>
      __$$_BookOrderCopyWithImpl<_$_BookOrder>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BookOrderToJson(this);
  }
}

abstract class _BookOrder implements BookOrder {
  factory _BookOrder(
      {@HiveField(0) required final int bookId,
      @HiveField(1) required final String customerName}) = _$_BookOrder;

  factory _BookOrder.fromJson(Map<String, dynamic> json) =
      _$_BookOrder.fromJson;

  @override
  @HiveField(0)
  int get bookId;
  @override
  @HiveField(1)
  String get customerName;
  @override
  @JsonKey(ignore: true)
  _$$_BookOrderCopyWith<_$_BookOrder> get copyWith =>
      throw _privateConstructorUsedError;
}
