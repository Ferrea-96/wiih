import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/notes_util.dart';
import 'package:wiih/classes/wine/wine_notes.dart';
import 'package:wiih/pages/add_wine_notes_page.dart';
import 'package:wiih/pages/edit_wine_notes_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late NotesList notesList;
  String selectedSortOption = 'None';

  @override
  void initState() {
    super.initState();
    // Initialize wineList in the initState method
    notesList = Provider.of<NotesList>(context, listen: false);
    NotesUtil.loadNotes;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Consumer<NotesList>(
            builder: (context, notesList, child) {
              final wineNotes = notesList.wineNotes;
              return Expanded(
                child: ListView.builder(
                  itemCount: wineNotes.length,
                  itemBuilder: (context, index) {
                    return _buildWineNoteCard(context, wineNotes[index]);
                  },
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15,15,15,25),
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToAddNotePage(
                        context);
                  },
                  child: const Text('Add'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15,15,15,25),
                child: ElevatedButton(
                  onPressed: () {
                    _showSortOptions(context);
                  },
                  child: const Text('Sort'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWineNoteCard(BuildContext context, WineNote wineNote) {
    return Card(
        child: InkWell(
      onTap: () {
        _navigateToEditNotePage(context, wineNote);
      },
      child: ListTile(
        title: Text(
          '${wineNote.name} ${wineNote.year}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .secondaryContainer,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            '${wineNote.rating}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ));
  }

  void _sortWineNotes() async {
    switch (selectedSortOption) {
      case 'Name':
        notesList.sortWineNotesByName();
        break;
      case 'Year':
        notesList.sortWineNotesByYear();
        break;
      case 'Rating':
        notesList.sortWineNotesByRating();
        break;
    }
    await NotesUtil.saveNotes(notesList);
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSortOption('Name'),
              _buildSortOption('Year'),
              _buildSortOption('Rating'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String option) {
    return ListTile(
      title: Text(option),
      onTap: () {
        setState(() {
          selectedSortOption = option;
          _sortWineNotes();
        });
        Navigator.pop(context);
      },
    );
  }

  void _navigateToAddNotePage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWineNotePage()),
    );

    if (result != null && result is WineNote) {
      notesList.addWineNote(result);
      try {
        await NotesUtil.saveNotes(notesList);
      } catch (e) {
        throw ('Error saving wine notes: $e');
      }
    }
  }

  void _navigateToEditNotePage(BuildContext context, WineNote wineNote) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditWineNotePage(wineNote: wineNote)),
    );

    if (result != null && result is WineNote) {
      notesList.updateWineNote(result);
      await NotesUtil.saveNotes(notesList);
    } else if (result != null && result is bool && result) {
      notesList.deleteWineNote(wineNote.id);
      await NotesUtil.saveNotes(notesList);
    }
  }
}
