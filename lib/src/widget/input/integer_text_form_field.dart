import 'package:flutter/material.dart';

class IntegerTextFormField extends StatefulWidget {
  final int initialValue;
  final bool enabled;
  final InputDecoration decoration;
  final void Function(int value) onChanged;
  final void Function(int value) onSaved;
  final int minValue;
  final int maxValue;

  IntegerTextFormField({
    this.initialValue,
    this.enabled,
    this.decoration,
    this.onChanged,
    this.onSaved,
    this.minValue,
    this.maxValue,
  }) {
    assert((this.minValue == null && this.maxValue == null) ||
        this.minValue <= this.maxValue);
  }

  @override
  State<StatefulWidget> createState() => _IntegerTextFormFieldState();
}

class _IntegerTextFormFieldState extends State<IntegerTextFormField> {
  TextEditingController controller;

  @override
  void initState() {
    int curVal = _ensureMinMax(widget.initialValue);
    controller = TextEditingController(text: curVal.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      controller: controller,
      decoration: widget.decoration,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (value == "") {
          controller.text = "";
          widget.onChanged(_ensureMinMax(0));
        } else {
          var parsedValue = _ensureMinMax(_parseValue(value));
          if (controller.text != parsedValue.toString()) {
            controller.text = parsedValue.toString();
          }
          widget.onChanged(parsedValue);
        }
      },
      onSaved: (value) => widget.onSaved(_ensureMinMax(_parseValue(value))),
    );
  }

  int _ensureMinMax(int value) {
    if (widget.minValue != null && value < widget.minValue) {
      return widget.minValue;
    }
    if (widget.maxValue != null && value > widget.maxValue) {
      return widget.maxValue;
    }
    return value;
  }

  int _parseValue(String input) {
    var regexMatches = RegExp(r'(\d+)').allMatches(input);
    if (regexMatches == null) {
      return 0;
    } else {
      return int.parse(regexMatches.elementAt(0).group(0));
    }
  }
}
