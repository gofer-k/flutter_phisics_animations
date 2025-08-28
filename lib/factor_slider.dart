import 'package:flutter/material.dart';

import 'widgets/display_expression.dart';

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
    return Row(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.only(right: 4.0),
          child: DisplayExpression(context: context, expression: label, scale: 1.2),
        ),
        Expanded(
          child: Slider(
            value: _currentSliderValue,
            min: minValue,
            max: maxValue,
            onChanged: onChanged,
          ),
        ),
      ]
    );
  }
}