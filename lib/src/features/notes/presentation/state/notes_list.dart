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

  void sortWineNotesByName() {
    _wineNotes.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void sortWineNotesByYear() {
    _wineNotes.sort((a, b) => a.year.compareTo(b.year));
    notifyListeners();
  }

  void sortWineNotesByRating() {
    _wineNotes.sort((a, b) => a.rating.compareTo(b.rating));
    notifyListeners();
  }
}
