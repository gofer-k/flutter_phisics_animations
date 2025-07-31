import 'package:flutter/cupertino.dart';

class DynamicLabel extends StatelessWidget {
  final String labelText;

  const DynamicLabel({super.key, required this.labelText,});

  @override
  Widget build(BuildContext context) {
    return Text(labelText);
  }
}