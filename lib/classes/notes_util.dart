import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/wine_notes.dart';

class NotesUtil {
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
      throw ('Error loading wine notes: $e');
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
      throw ('Error saving wine notes: $e');
    }
  }
}
