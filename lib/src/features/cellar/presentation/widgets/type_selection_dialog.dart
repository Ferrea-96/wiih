import 'package:flutter/material.dart';
import 'package:wiih/src/features/cellar/domain/models/wine_options.dart';

class TypeSelectionDialog extends StatefulWidget {
  final String selectedType;

  const TypeSelectionDialog({super.key, required this.selectedType});

  @override
  State<TypeSelectionDialog> createState() => _TypeSelectionDialogState();
}

class _TypeSelectionDialogState extends State<TypeSelectionDialog> {
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Type'),
      content: SizedBox(
        height: 260,
        child: SingleChildScrollView(
          child: RadioGroup<String>(
            groupValue: _selectedType,
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedType = value);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: WineOptions.types
                  .map(
                    (type) => RadioListTile<String>(
                      title: Text(type),
                      value: type,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedType),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
