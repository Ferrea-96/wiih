import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiih/src/features/notes/presentation/state/notes_list.dart';
import 'package:wiih/src/features/notes/domain/models/wine_note.dart';

class NoteRepository {
  static Future<void> loadNotes(NotesList notesList) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? notesListJson = prefs.getString('notesList');

      if (notesListJson != null) {
        final List<dynamic> decodedJson = json.decode(notesListJson);
        final List<WineNote> loadedNotes = decodedJson
            .map((json) => WineNote.fromJson(json))
            .cast<WineNote>()
            .toList();
        notesList.loadWineNotes(loadedNotes);
      }
    } catch (e) {
      throw Exception('Error loading wine notes: $e');
    }
  }

  static Future<void> saveNotes(NotesList notesList) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> notesJsonList =
          notesList.wineNotes.map((wineNote) => wineNote.toJson()).toList();
      final String encodedJson = json.encode(notesJsonList);
      prefs.setString('notesList', encodedJson);
    } catch (e) {
      throw Exception('Error saving wine notes: $e');
    }
  }
}
