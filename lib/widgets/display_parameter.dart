import 'package:flutter/cupertino.dart';

import 'display_expression.dart';
import '../dynamic_label.dart';

class DisplayParameter<T> extends StatefulWidget {
  final String label;
  final String? unit;
  final T value;
  final double? scale;

  const DisplayParameter({super.key, required this.label, required this.value, this.unit, this.scale});

  @override
  State<StatefulWidget> createState() => DisplayParameterState(label, value, unit, scale ?? 1.0);
}

class DisplayParameterState<T> extends State<DisplayParameter> {
  final String label;
  final String? unit;
  final T value;
  double scale = 1.0;

  DisplayParameterState(this.label, this.value, this.unit, this.scale);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DisplayExpression(context: context, expression: label, scale: scale),
        DynamicLabel(labelText: (value is double) ? (value as double).toStringAsFixed(2) : value.toString()),
        if (unit != null)
          DisplayExpression(context: context, expression: unit!, scale: scale)
      ],
    );
  }
}