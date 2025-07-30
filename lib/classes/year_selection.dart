import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

Future<int?> showYearPickerDialog(BuildContext context, int currentValue) async {
  final int maxYear = DateTime.now().year;
  int selected = currentValue;

  return await showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Year'),
            content: NumberPicker(
              value: selected,
              minValue: 1900,
              maxValue: maxYear,
              axis: Axis.vertical,
              onChanged: (value) => setState(() => selected = value),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(selected),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}