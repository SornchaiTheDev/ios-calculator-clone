import 'package:calculator/enums/pad_button_type.dart';
import 'package:flutter/material.dart';

class PadButtonModel {
  const PadButtonModel({
    required this.value,
    required this.onPressed,
    this.fontSize = 32.0,
    this.color = Colors.grey,
    this.type = PadButtonType.operand,
    this.flex = 1,
  });

  final Object value;
  final Color color;
  final double fontSize;
  final int flex;
  final PadButtonType type;
  final VoidCallback? onPressed;
}
