import 'package:flutter/material.dart';
import 'package:wiih/classes/wine.dart';

class TypeSelectionDialog extends StatefulWidget {
  final String selectedType;

  TypeSelectionDialog({required this.selectedType});

  @override
  _TypeSelectionDialogState createState() =>
      _TypeSelectionDialogState(selectedType: selectedType);
}

class _TypeSelectionDialogState extends State<TypeSelectionDialog> {
  String selectedType;

  _TypeSelectionDialogState({required this.selectedType});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: const Text('Select Type'),
        content: Column(
          children: WineOptions.types
              .map(
                (type) => RadioListTile(
                  title: Text(type),
                  value: type,
                  groupValue: selectedType,
                  onChanged: (String? value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, selectedType);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
