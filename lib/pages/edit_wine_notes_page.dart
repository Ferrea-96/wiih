import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:wiih/classes/wine/wine_notes.dart';

class EditWineNotePage extends StatefulWidget {
  final WineNote wineNote;

  const EditWineNotePage({Key? key, required this.wineNote}) : super(key: key);

  @override
  _EditWineNotePageState createState() => _EditWineNotePageState();
}

class _EditWineNotePageState extends State<EditWineNotePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int _rating = 50;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.wineNote.name;
    _yearController.text = widget.wineNote.year.toString();
    _descriptionController.text = widget.wineNote.description;
    _rating = widget.wineNote.rating;
  }

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
                  textCapitalization: TextCapitalization.words,
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Wine Name',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Tasting Notes',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
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
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _saveNote();
                    },
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _deleteNote(context);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveNote() {
    if (_nameController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final int yearValue = int.tryParse(_yearController.text) ?? 0;
    if (yearValue < 1900 || yearValue > DateTime.now().year) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid year')),
      );
      return;
    }

    final editedNote = WineNote(
      id: widget.wineNote.id,
      name: _nameController.text,
      year: yearValue,
      description: _descriptionController.text,
      rating: _rating,
    );

    Navigator.pop(context, editedNote);
  }

  void _deleteNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this wine note?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              Navigator.pop(context, true); // Pass true to indicate deletion
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
