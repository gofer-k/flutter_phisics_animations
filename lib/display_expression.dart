import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/ast.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class display_expression extends StatelessWidget {
  const display_expression({
    super.key,
    required this.context,
    required this.expression,
    required this.scale,
    required this.widgetWidth,
  });

  final BuildContext context;
  final String expression;
  final double scale;
  final double widgetWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: widgetWidth,
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Optional: add some vertical padding
      // decoration: BoxDecoration(border: Border.all(color: Colors.red)), // Optional: for debugging width
      child: Math.tex(
        expression,
        // textStyle: Theme.of(context).textTheme.bodySmall, // You might need to adjust this
        // The flutter_math_fork package uses its own text scaling.
        // You might need to adjust 'mathStyle' or 'textScaleFactor' if the default rendering is too small/large.
        // For example, to make it larger if it becomes too small when constrained:
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18), // Start with a base style
        mathStyle: MathStyle.display, // Or .text, .script, .scriptScript
        textScaleFactor: scale, // Adjust this factor as needed
        onErrorFallback: (FlutterMathException e) { // Good practice to have an error fallback
          return Text(
            'Error rendering formula: ${e.message}',
            style: const TextStyle(color: Colors.red),
          );
        },
      ),
    );
  }
}