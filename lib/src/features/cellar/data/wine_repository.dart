import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiih/src/features/cellar/presentation/state/wine_list.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';

class WineRepository {
  /// Loads wines from SharedPreferences and Firestore (if logged in)
  static Future<void> loadWines(WineList wineList) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('wines')
            .get();

        final wines =
            snapshot.docs.map((doc) => Wine.fromJson(doc.data())).toList();

        wineList.loadWines(wines);
        return;
      } catch (e) {
        // fallback to SharedPreferences
      }
    }

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

  /// Saves wines to SharedPreferences and Firestore (if logged in)
  static Future<void> saveWines(WineList wineList) async {
    // SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final wineJsonList =
          wineList.allWines.map((wine) => wine.toJson()).toList();
      await prefs.setStringList(
        'wineList',
        wineJsonList.map((e) => json.encode(e)).toList(),
      );
    } catch (e) {
      // Unable to persist locally; let cloud sync handle current state
    }

    // Firebase Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final CollectionReference wineRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wines');

      try {
        // Clear previous cloud data
        final oldDocs = await wineRef.get();
        for (var doc in oldDocs.docs) {
          await doc.reference.delete();
        }

        // Save current list
        for (var wine in wineList.allWines) {
          await wineRef.add(wine.toJson());
        }
      } catch (e) {
        // Log or handle error
      }
    }
  }

  /// Clears all saved wines locally and optionally from Firestore
  static Future<void> clearWines({bool alsoFromCloud = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wineList');

    if (alsoFromCloud) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final wineRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('wines');
        final docs = await wineRef.get();
        for (var doc in docs.docs) {
          await doc.reference.delete();
        }
      }
    }
  }
}
