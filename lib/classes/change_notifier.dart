import 'package:flutter/material.dart';
import 'package:wiih/classes/wine/wine.dart';
import 'package:wiih/classes/wine/wine_notes.dart';

class WineList with ChangeNotifier {
  bool _isFiltered = false;
  List<Wine> get wines => _isFiltered ? _filteredWines : _wines;
  List<Wine> _wines = [];
  List<Wine> _filteredWines = [];


  void addWine(Wine wine) {
    _wines.add(wine);
    notifyListeners();
  }

  void updateWine(Wine updatedWine) {
    int index = _wines.indexWhere((wine) => wine.id == updatedWine.id);
    if (index != -1) {
      _wines[index] = updatedWine;
      notifyListeners();
    }
  }

  void deleteWine(int wineId) {
    _wines.removeWhere((wine) => wine.id == wineId);
    notifyListeners();
  }

  void sortWinesByPrice() {
    _wines.sort((a, b) => a.price.compareTo(b.price));
    notifyListeners();
  }

  void sortWinesByType() {
    _wines.sort((a, b) => a.type.compareTo(b.type));
    notifyListeners();
  }

  void sortWinesByCountry() {
    _wines.sort((a, b) => a.country.compareTo(b.country));
    notifyListeners();
  }

  void sortWinesByYear() {
    _wines.sort((a, b) => a.year.compareTo(b.year));
    notifyListeners();
  }

  void sortWinesByName() {
    _wines.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  void loadWines(List<Wine> wines) {
    _wines = wines;
    notifyListeners();
  }

  
  void filterWinesByType(String type) {
    _filteredWines = _wines.where((wine) => wine.type == type).toList();
    _isFiltered = true;
    notifyListeners();
  }

  void clearFilter() {
    _filteredWines.clear();
    _isFiltered = false;
    notifyListeners();
}
}

class NotesList with ChangeNotifier {
  List<WineNote> _wineNotes = [];

  List<WineNote> get wineNotes => _wineNotes;

  void addWineNote(WineNote wineNote) {
    _wineNotes.add(wineNote);
    notifyListeners();
  }

  void updateWineNote(WineNote updatedWineNote) {
    int index =
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
    _wineNotes = wineNotes;
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
