import 'package:calculator/enums/value_type.dart';

class Atom {
  Atom({
    required this.value,
    required this.type,
  });

  String value;
  ValueType type;
}
