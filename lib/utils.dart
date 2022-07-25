import 'package:flutter/cupertino.dart';

Color parseColor(String color) {
  return Color(int.parse(color, radix: 16) + 0xFF000000);
}