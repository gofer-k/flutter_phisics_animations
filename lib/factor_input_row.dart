import 'package:first_flutter_app/display_expression.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter

class FactorInputRow extends StatelessWidget {
  final String label;
  final String? unit;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged; // Callback for when the value changes
  final List<TextInputFormatter>? inputFormatters;

  const FactorInputRow({
    super.key,
    required this.label,
    this.unit,
    required this.controller,
    this.hintText,
    this.keyboardType = TextInputType.number,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2, // Give more space to the label
            child: DisplayExpression(context: context, expression: label, scale: 1.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3, // Give more space to the text field
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText ?? "Enter value",
                isDense: true, // Makes the field a bit more compact
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                border: const OutlineInputBorder(),
              ),
              keyboardType: keyboardType,
              onChanged: onChanged,
              inputFormatters: inputFormatters ?? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))], // Default: allow numbers and one dot
              textAlign: TextAlign.end, // Align text to the right, closer to the unit
            ),
          ),
          const SizedBox(width: 8),
          if (unit != null)
            SizedBox(
              width: 40, // Fixed width for the unit to ensure alignment
              child: DisplayExpression(context: context, expression: unit!, scale: 1.5)
          ) else SizedBox.shrink()
        ],
      ),
    );
  }
}