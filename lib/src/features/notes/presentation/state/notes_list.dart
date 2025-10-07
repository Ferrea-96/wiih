import 'package:flutter/foundation.dart';
import 'package:wiih/src/features/notes/domain/models/wine_note.dart';

class NotesList with ChangeNotifier {
  List<WineNote> _wineNotes = [];

  List<WineNote> get wineNotes => _wineNotes;

  void addWineNote(WineNote wineNote) {
    _wineNotes.add(wineNote);
    notifyListeners();
  }

  void updateWineNote(WineNote updatedWineNote) {
    final index =
        _wineNotes.indexWhere((wineNote) => wineNote.id == updatedWineNote.id);
    if (index != -1) {
      _wineNotes[index] = updatedWineNote;
      notifyListeners();
    }
  }

  void deleteWineNote(int wineNoteId) {
    _wineNotes.removeWhere((wineNote) => wineNoteId == wineNote.id);
    notifyListeners();
  }

  void loadWineNotes(List<WineNote> wineNotes) {
    _wineNotes = List<WineNote>.from(wineNotes);
    notifyListeners();
  }

  void sortWineNotesByName({bool descending = false}) {
    _wineNotes.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      return descending ? bName.compareTo(aName) : aName.compareTo(bName);
    });
    notifyListeners();
  }

  void sortWineNotesByYear({bool descending = false}) {
    _wineNotes.sort((a, b) =>
        descending ? b.year.compareTo(a.year) : a.year.compareTo(b.year));
    notifyListeners();
  }

  void sortWineNotesByRating({bool descending = false}) {
    _wineNotes.sort((a, b) => descending
        ? b.rating.compareTo(a.rating)
        : a.rating.compareTo(b.rating));
    notifyListeners();
  }
}
