import 'package:calculator/enums/pad_button_type.dart';
import 'package:calculator/models/pad_button.dart';
import 'package:flutter/material.dart';

class PadButton extends StatelessWidget {
  const PadButton(
    this.padButton, {
    super.key,
  });

  final PadButtonModel padButton;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: padButton.flex,
      child: SizedBox(
        width: 80.0,
        height: 80,
        child: ElevatedButton(
          onPressed: padButton.onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(padButton.color),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
          child: padButton.type == PadButtonType.icon
              ? Icon(
                  padButton.value as IconData,
                  color: Colors.white,
                )
              : Text(
                  padButton.value as String,
                  style: TextStyle(
                    fontSize: padButton.fontSize,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

// Utils function
bool isOperator(String value) {
  var operatorRegEx = RegExp(r'\+|\|-|\*|/');
  bool isOperator = operatorRegEx.hasMatch(value);
  return isOperator;
}

bool isOperand(String value) {
  var operandRegEx = RegExp(r'\d');
  bool isOperand = operandRegEx.hasMatch(value);
  return isOperand;
}

bool isHasOperator(String value) {
  var operatorRegEx = RegExp(r'[+\-*/]+');
  bool isHasOperator = operatorRegEx.hasMatch(value);
  return isHasOperator;
}

bool isHasOperand(String value) {
  var operatorRegEx = RegExp(r'\d+');
  bool isHasOperand = operatorRegEx.hasMatch(value);
  return isHasOperand;
}

bool isLastCharacterOperator(String value) {
  String lastChar = value[value.length - 1];

  return isOperator(lastChar);
}
