import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/wine/wine.dart';

class WinesUtil {
  /// Loads wines from SharedPreferences and injects them into the given WineList.
  static Future<void> loadWines(WineList wineList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? wineListJson = prefs.getStringList('wineList');

      if (wineListJson != null) {
        final loadedWines = wineListJson
            .map((json) => Wine.fromJson(jsonDecode(json)))
            .toList();
        wineList.loadWines(loadedWines);
      }
    } catch (e) {
      wineList.loadWines([]); // fallback
    }
  }

  /// Saves the current list of wines into SharedPreferences.
  static Future<void> saveWines(WineList wineList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wineJsonList =
          wineList.wines.map((wine) => wine.toJson()).toList();
      await prefs.setStringList(
        'wineList',
        wineJsonList.map((e) => json.encode(e)).toList(),
      );
    } catch (e) {
    }
  }

  /// Clears all saved wines from SharedPreferences.
  static Future<void> clearWines() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wineList');
  }
}
