// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/wine_notes.dart';

class AddWineNotePage extends StatefulWidget {
  const AddWineNotePage({Key? key}) : super(key: key);

  @override
  _AddWineNotePageState createState() => _AddWineNotePageState();
}

class _AddWineNotePageState extends State<AddWineNotePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int _rating = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Wine Name',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Year',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Tasting Notes',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  maxLines: 6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text('Rating: '),
                    NumberPicker(
                      value: _rating,
                      minValue: 50,
                      maxValue: 100,
                      axis: Axis.horizontal,
                      selectedTextStyle: TextStyle(
                        fontSize: 28,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _rating = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _saveNote(
                    context,
                    _nameController.text,
                    _yearController.text,
                    _descriptionController.text,
                    _rating,
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveNote(
    BuildContext context,
    String name,
    String year,
    String description,
    int rating,
  ) {
    if (name.isEmpty || year.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final int yearValue = int.tryParse(year) ?? 0;
    if (yearValue < 1900 || yearValue > DateTime.now().year) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid year')),
      );
      return;
    }

    final WineNote newNote = WineNote(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      year: yearValue,
      description: description,
      rating: rating,
    );

    Provider.of<NotesList>(context, listen: false).addWineNote(newNote);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved successfully')),
    );
    Navigator.pop(context);
  }
}
