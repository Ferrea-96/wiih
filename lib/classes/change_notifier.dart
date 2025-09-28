import 'package:flutter/material.dart';
import 'package:wiih/classes/wine/wine.dart';
import 'package:wiih/classes/wine/wine_notes.dart';

class WineList with ChangeNotifier {
  List<Wine> _wines = [];
  List<Wine> _filteredWines = [];
  bool _isFiltered = false;
  String? _activeFilterType;

  List<Wine> get wines => _isFiltered ? _filteredWines : _wines;

  List<Wine> get allWines => List.unmodifiable(_wines);

  void addWine(Wine wine) {
    _wines.add(wine);
    _refreshFilteredWines();
    notifyListeners();
  }

  void updateWine(Wine updatedWine) {
    final index = _wines.indexWhere((wine) => wine.id == updatedWine.id);
    if (index != -1) {
      _wines[index] = updatedWine;
      _refreshFilteredWines();
      notifyListeners();
    }
  }

  void deleteWine(int wineId) {
    final initialLength = _wines.length;
    _wines.removeWhere((wine) => wine.id == wineId);
    if (_wines.length != initialLength) {
      _refreshFilteredWines();
      notifyListeners();
    }
  }

  void sortWinesByPrice() {
    _wines.sort((a, b) => a.price.compareTo(b.price));
    _refreshFilteredWines();
    notifyListeners();
  }

  void sortWinesByType() {
    _wines.sort((a, b) => a.type.compareTo(b.type));
    _refreshFilteredWines();
    notifyListeners();
  }

  void sortWinesByCountry() {
    _wines.sort((a, b) => a.country.compareTo(b.country));
    _refreshFilteredWines();
    notifyListeners();
  }

  void sortWinesByYear() {
    _wines.sort((a, b) => a.year.compareTo(b.year));
    _refreshFilteredWines();
    notifyListeners();
  }

  void sortWinesByName() {
    _wines.sort((a, b) => a.name.compareTo(b.name));
    _refreshFilteredWines();
    notifyListeners();
  }

  void loadWines(List<Wine> wines) {
    _wines = List<Wine>.from(wines);
    _refreshFilteredWines();
    notifyListeners();
  }

  void filterWinesByType(String type) {
    _activeFilterType = type;
    _refreshFilteredWines();
    notifyListeners();
  }

  void clearFilter() {
    if (!_isFiltered && _activeFilterType == null) {
      return;
    }

    _activeFilterType = null;
    _refreshFilteredWines();
    notifyListeners();
  }

  void _refreshFilteredWines() {
    if (_activeFilterType == null) {
      _filteredWines = [];
      _isFiltered = false;
      return;
    }

    _filteredWines = _wines.where((wine) => wine.type == _activeFilterType).toList();
    _isFiltered = true;
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

