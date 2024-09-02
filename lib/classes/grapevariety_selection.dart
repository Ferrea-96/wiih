import 'package:flutter/material.dart';

class GrapeVarietySelectionDialog extends StatefulWidget {
  final List<String> grapeVarieties;
  final Set<String> selectedValues;

   GrapeVarietySelectionDialog({
    required this.grapeVarieties,
    required this.selectedValues,
  });

  @override
  GrapeVarietySelectionDialogState createState() =>
      GrapeVarietySelectionDialogState();
}

class GrapeVarietySelectionDialogState extends State<GrapeVarietySelectionDialog> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: const Text('Select Grape Varieties'),
        content: Column(
          children: widget.grapeVarieties
              .map(
                (grape) => CheckboxListTile(
                  title: Text(grape),
                  value: widget.selectedValues.contains(grape),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null) {
                        if (value) {
                          widget.selectedValues.add(grape);
                        } else {
                          widget.selectedValues.remove(grape);
                        }
                      }
                    });
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, widget.selectedValues.toList());
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
