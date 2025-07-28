import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/wine/wine.dart';

class WinesUtil {
  static Future<void> loadWines(WineList wineList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? wineListJson = prefs.getStringList('wineList');

    if (wineListJson != null) {
      List<Wine> loadedWines =
          wineListJson.map((json) => Wine.fromJson(jsonDecode(json))).toList();
      wineList.loadWines(loadedWines);
    }
  }

  static Future<void> saveWines(WineList wineList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> wineJsonList =
        wineList.wines.map((wine) => wine.toJson()).toList();
    prefs.setStringList(
        'wineList', wineJsonList.map((e) => json.encode(e)).toList());
  }
}
