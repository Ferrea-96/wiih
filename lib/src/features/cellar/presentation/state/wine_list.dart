import 'package:flutter/foundation.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';

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

    _filteredWines =
        _wines.where((wine) => wine.type == _activeFilterType).toList();
    _isFiltered = true;
  }
}
