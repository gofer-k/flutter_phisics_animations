import 'package:flutter/cupertino.dart';

class DynamicLabel extends StatelessWidget {
  final String labelText;

  DynamicLabel({Key? key, required this.labelText,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(labelText);
  }
}