import 'package:flutter/cupertino.dart';

class DynamicLabel extends StatefulWidget {
  final String labelText;
  // Add a callback to update the label what this is used in te external/parent widget
  final void Function(String) onUpdateLabel;

  DynamicLabel({Key? key,
    required this.labelText,
    required this.onUpdateLabel}) : super(key: key);

  @override
  State<DynamicLabel> createState() => _DynamicLabelState();
}

class _DynamicLabelState extends State<DynamicLabel> {
  late String _currentLabel;

  @override
  void initState() {
    super.initState();
    _currentLabel = widget.labelText;
  }

  // Method that can be called by the parent to update the label
  void updateLabel(String newLabel) {
    if (mounted) {
      setState(() {
        _currentLabel = newLabel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Register the callback so the parent can update this widget
    // WidgetBinding.instance.addPostFrameCallback((_) {
    //   widget.onUpdateLabel(updateLabel);
    // }

    return Text(_currentLabel);
  }
}