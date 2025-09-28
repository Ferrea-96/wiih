import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/src/features/notes/data/note_repository.dart';
import 'package:wiih/src/features/notes/domain/models/wine_note.dart';
import 'package:wiih/src/features/notes/presentation/state/notes_list.dart';
import 'package:wiih/src/features/notes/presentation/pages/add_wine_note_page.dart';
import 'package:wiih/src/features/notes/presentation/pages/edit_wine_note_page.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NoteRepository.loadNotes(notesList);
    });
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
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 25),
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToAddNotePage(context);
                  },
                  child: const Text('Add'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 25),
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
            color: Theme.of(context).colorScheme.secondaryContainer,
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

  Future<void> _sortWineNotes() async {
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
    await _persistNotes();
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
        Navigator.pop(context);
        setState(() {
          selectedSortOption = option;
        });
        unawaited(_sortWineNotes());
      },
    );
  }

  Future<void> _persistNotes() async {
    try {
      await NoteRepository.saveNotes(notesList);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save wine notes: $e')),
      );
    }
  }

  Future<void> _navigateToAddNotePage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWineNotePage()),
    );
    if (result != null && result is WineNote) {
      notesList.addWineNote(result);
      await _persistNotes();
    }
  }

  Future<void> _navigateToEditNotePage(
      BuildContext context, WineNote wineNote) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditWineNotePage(wineNote: wineNote)),
    );
    if (result != null && result is WineNote) {
      notesList.updateWineNote(result);
      await _persistNotes();
    } else if (result != null && result is bool && result) {
      notesList.deleteWineNote(wineNote.id);
      await _persistNotes();
    }
  }
}
