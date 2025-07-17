import 'package:flutter/material.dart';

import 'display_expression.dart';

class FactorSlider extends StatelessWidget {
  final String label;
  final double initialValue;
  final double minValue;
  final double maxValue;
  final ValueChanged<double>? onChanged;

  const FactorSlider({
    super.key,
    required this.label,
    required this.initialValue,
    required this.minValue,required this.maxValue,
    required this.onChanged,});

  double get _currentSliderValue => initialValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3, // Give more space to the label
              child: DisplayExpression(context: context, expression: label, scale: 1.2),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 4, // Give more space to the slider
              child: Slider(
                value: _currentSliderValue,
                min: minValue,
                max: maxValue,
                // label: SliderThemeData.showValueIndicator,
                onChanged: onChanged,
              ),
            ),
          ]
        ),
    );
  }
}