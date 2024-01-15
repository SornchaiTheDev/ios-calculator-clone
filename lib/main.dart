import "package:calculator/components/pad_button.dart";
import "package:calculator/constants/number.dart";
import "package:calculator/constants/operator.dart";
import 'package:calculator/models/pad_button.dart';
import "package:flutter/material.dart";
import "package:math_expressions/math_expressions.dart";
import 'package:calculator/enums/value_type.dart';
import 'package:calculator/models/atom.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
      ),
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        body: const MyCalculator(),
      ),
    );
  }
}

class MyCalculator extends StatefulWidget {
  const MyCalculator({
    super.key,
  });

  @override
  State<MyCalculator> createState() => _MyCalculatorState();
}

class _MyCalculatorState extends State<MyCalculator> {
  String expression = "";
  String operand = "";
  bool isCalculated = false;
  bool isError = false;
  var histories = [];
  Offset? lastOffset;

  void calculate() {
    if (!isHasOperand(expression) ||
        !isHasOperator(expression) ||
        expression.isEmpty) {
      setState(() {
        isError = true;
      });
      return;
    }

    try {
      ContextModel cm = ContextModel();
      Parser p = Parser();
      Expression exp = p.parse(expression);
      var result = exp.evaluate(EvaluationType.REAL, cm);

      bool isIntResult = result % 1 == 0;
      bool isLargeResult = result >= hundredMillion;
      bool isTinyResult = result <= tenDecimalPoint;

      setState(() {
        String finalResult = "";
        if (isIntResult) {
          int intResult = result.toInt();
          if (isLargeResult) {
            finalResult = intResult.toStringAsExponential(3);
          } else {
            finalResult = intResult.toString();
          }
        } else {
          if (isLargeResult || isTinyResult) {
            finalResult = result.toStringAsExponential(3);
          } else {
            finalResult = result.toString();
          }
        }

        operand = finalResult;
        histories.insert(0, "$expression = $finalResult");
        isCalculated = true;
      });
    } catch (err) {
      setState(() {
        operand = "Error";
      });
    }
  }

  void handleOnPressClear() {
    setState(() {
      operand = "";
      expression = "";
    });
  }

  void handleOnPressNumber(String number) {
    setState(() {
      if (operand.length >= 9) return;

      isCalculated = false;
      operand += number;
      expression += number;
    });
  }

  void handleOnPressOperator(String operator) {
    if (expression.isEmpty) return;
    setState(() {
      if (isCalculated) {
        expression = "$operand $operator";
      } else {
        expression += operator;
      }
      isCalculated = false;
      operand = "";
    });
  }

  void handleOnPressOpposite() {
    if (expression.isEmpty) return;
    setState(() {
      if (operand.contains("-")) {
        operand = operand.substring(1, operand.length);
      } else {
        operand = "-$operand";
      }

      RegExp plusAndMinusOperator = RegExp(r'[+\-]');
      RegExp otherOperator = RegExp(r'[*\/]');
      int lastOperatorIndex = expression.lastIndexOf(plusAndMinusOperator);

      if (lastOperatorIndex == -1) {
        lastOperatorIndex = expression.lastIndexOf(otherOperator) + 1;
      }

      expression = expression.substring(0, lastOperatorIndex);

      if (expression.contains(otherOperator)) {
        expression += operand;
      } else {
        if (operand.contains("-")) {
          expression += operand;
          return;
        }
        expression += "+$operand";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var padButtonRows = [
      [
        PadButtonModel(
          value: "C",
          onPressed: handleOnPressClear,
        ),
        PadButtonModel(
            value: "+/-", fontSize: 22.0, onPressed: handleOnPressOpposite),
        PadButtonModel(
            value: "%",
            onPressed: () {
              if (expression.isEmpty) return;
              setState(() {
                expression = "($expression) / 100";
              });
            }),
        PadButtonModel(
            value: divide,
            color: Colors.orange,
            onPressed: () => handleOnPressOperator("/")),
      ],
      [
        PadButtonModel(value: "7", onPressed: () => handleOnPressNumber("7")),
        PadButtonModel(value: "8", onPressed: () => handleOnPressNumber("8")),
        PadButtonModel(value: "9", onPressed: () => handleOnPressNumber("9")),
        PadButtonModel(
            value: multiply,
            color: Colors.orange,
            onPressed: () => handleOnPressOperator("*")),
      ],
      [
        PadButtonModel(value: "4", onPressed: () => handleOnPressNumber("4")),
        PadButtonModel(value: "5", onPressed: () => handleOnPressNumber("5")),
        PadButtonModel(value: "6", onPressed: () => handleOnPressNumber("6")),
        PadButtonModel(
            value: minus,
            color: Colors.orange,
            onPressed: () => handleOnPressOperator("-")),
      ],
      [
        PadButtonModel(value: "1", onPressed: () => handleOnPressNumber("1")),
        PadButtonModel(value: "2", onPressed: () => handleOnPressNumber("2")),
        PadButtonModel(value: "3", onPressed: () => handleOnPressNumber("3")),
        PadButtonModel(
            value: plus,
            color: Colors.orange,
            onPressed: () => handleOnPressOperator("+")),
      ],
      [
        PadButtonModel(
            value: "0", flex: 2, onPressed: () => handleOnPressNumber("0")),
        PadButtonModel(value: ".", onPressed: () => handleOnPressNumber(".")),
        PadButtonModel(value: "=", color: Colors.orange, onPressed: calculate),
      ]
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: histories
                        .expand(
                          (history) => [
                            buildOperationPlaceholder(history, fontSize: 32.0),
                            const SizedBox(height: 10.0)
                          ],
                        )
                        .toList())
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                color: Colors.grey[800]?.withOpacity(0.25),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      buildOperationPlaceholder(expression),
                      GestureDetector(
                        onHorizontalDragEnd: onSwipeEnd,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            operand.isEmpty ? "0" : operand,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 64.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: padButtonRows
                      .map((row) => buildPadRow(row.toList()))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column buildPadRow(List<PadButtonModel> items) {
    return Column(
      children: [
        Row(
          children: items
              .expand((element) => [
                    if (element != items.first) const SizedBox(width: 12.0),
                    PadButton(element),
                  ])
              .toList(),
        ),
        const SizedBox(
          height: 16.0,
        ),
      ],
    );
  }

  Wrap buildOperationPlaceholder(String operation, {double fontSize = 20.0}) {
    var splitedOperation = operation.split("");
    List<Atom> atoms = [];

    for (String element in splitedOperation) {
      bool isOperand = double.tryParse(element) != null;

      if (isOperand) {
        atoms.add(Atom(value: element, type: ValueType.operand));
      } else if (isHasOperator(element)) {
        String transformSymbol = "";
        switch (element) {
          case "+":
            transformSymbol = plus;
          case "-":
            transformSymbol = minus;
          case "*":
            transformSymbol = multiply;
          case "/":
            transformSymbol = divide;
        }
        atoms.add(Atom(value: transformSymbol, type: ValueType.operator));
      } else {
        atoms.add(Atom(value: element, type: ValueType.other));
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: atoms
          .map((element) {
            if (element.type == ValueType.operand) {
              return Text(
                element.value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            if (element.type == ValueType.operator) {
              return Text(
                element.value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            return Text(
              element.value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            );
          })
          .map(
            (element) => Container(
              margin: const EdgeInsets.only(left: 4.0),
              child: element,
            ),
          )
          .toList(),
    );
  }

  void onSwipeEnd(DragEndDetails details) {
    bool isSwiped = details.primaryVelocity != 0;
    if (isSwiped) {
      setState(() {
        if (operand.isNotEmpty) {
          operand = operand.substring(0, operand.length - 1);
        }
      });
    }
  }
}
