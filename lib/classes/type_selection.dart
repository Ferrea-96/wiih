import 'package:flutter/material.dart';
import 'package:wiih/classes/wine/wine_options.dart';

class TypeSelectionDialog extends StatefulWidget {
  final String selectedType;

  const TypeSelectionDialog({required this.selectedType});

  @override
  // ignore: library_private_types_in_public_api
  _TypeSelectionDialogState createState() =>
      _TypeSelectionDialogState(selectedType: selectedType);
}

class _TypeSelectionDialogState extends State<TypeSelectionDialog> {
  String selectedType;

  _TypeSelectionDialogState({required this.selectedType});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Type'),
      content: SizedBox(
        height: 260, // Constrain the height of the dialog
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedType);
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}
