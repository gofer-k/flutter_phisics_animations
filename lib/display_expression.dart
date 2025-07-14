import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class DisplayExpression extends StatefulWidget {
  const DisplayExpression({super.key,
    required this.context,
    required this.expression,
    required this.scale,
  });

  final BuildContext context;
  final String expression;
  final double scale;

  @override
  State<DisplayExpression> createState() => DisplayExpressionState();
}

class DisplayExpressionState extends State<DisplayExpression> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Optional: add some vertical padding
      child: Math.tex(
        widget.expression,
        textStyle: Theme.of(context).textTheme.bodyMedium, // Start with a base style
        mathStyle: MathStyle.display, // Or .text, .script, .scriptScript
        textScaleFactor: widget.scale, // Adjust this factor as needed
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