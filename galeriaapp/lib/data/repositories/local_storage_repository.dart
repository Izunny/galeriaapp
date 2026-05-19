import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/wallpaper.dart';
import '../models/wallpaper_model.dart';

// Esta clase se encarga de manejar el almacenamiento local de datos relacionados con los wallpapers y el historial de búsqueda,
class LocalStorageRepository {
  static const String favoritesKey = 'favorites';
  static const String downloadsKey = 'downloads';
  static const String searchHistoryKey = 'search_history';
  // utilizando SharedPreferences para guardar y recuperar esta información de manera persistente en el dispositivo del usuario.
  final SharedPreferences prefs;

  LocalStorageRepository(this.prefs);

  List<Wallpaper> loadWallpapers(String storageKey) {
    final storedItems = prefs.getStringList(storageKey) ?? <String>[];

    return storedItems.map((item) {
      final decodedItem = jsonDecode(item) as Map<String, dynamic>;
      return WallpaperModel.fromCacheJson(decodedItem);
    }).toList();
  }

  Future<List<Wallpaper>> saveWallpapers(
    String storageKey,
    List<Wallpaper> wallpapers,
  ) async {
    final encodedWallpapers = wallpapers
        .map((wallpaper) => jsonEncode(_toJson(wallpaper)))
        .toList();

    await prefs.setStringList(storageKey, encodedWallpapers);
    return wallpapers;
  }

  // Los métodos de esta clase permiten cargar y guardar listas de wallpapers en SharedPreferences
  //utilizando claves específicas para cada tipo de dato (favoritos, descargas, historial de búsqueda),
  //y también proporcionan funciones para agregar, eliminar y verificar la existencia de wallpapers en estas listas,
  // así como para manejar el historial de búsqueda del usuario.
  Future<List<Wallpaper>> addWallpaper(
    String storageKey,
    Wallpaper wallpaper, {
    bool insertAtStart = true,
  }) async {
    final currentWallpapers = loadWallpapers(storageKey);
    final filteredWallpapers = currentWallpapers
        .where((item) => item.id != wallpaper.id)
        .toList();

    final updatedWallpapers = insertAtStart
        ? [wallpaper, ...filteredWallpapers]
        : [...filteredWallpapers, wallpaper];

    return saveWallpapers(storageKey, updatedWallpapers);
  }

  // Este método agrega un wallpaper a la lista almacenada bajo la clave especificada,
  //asegurándose de no duplicar entradas y permitiendo controlar si el nuevo wallpaper se inserta al inicio o al final de la lista.
  Future<List<Wallpaper>> removeWallpaper(
    String storageKey,
    String wallpaperId,
  ) async {
    final currentWallpapers = loadWallpapers(storageKey);
    final updatedWallpapers = currentWallpapers
        .where((item) => item.id != wallpaperId)
        .toList();

    return saveWallpapers(storageKey, updatedWallpapers);
  }

  bool containsWallpaper(String storageKey, String wallpaperId) {
    return loadWallpapers(storageKey).any((item) => item.id == wallpaperId);
  }

  List<String> loadSearchHistory() {
    return prefs.getStringList(searchHistoryKey) ?? <String>[];
  }

  Future<List<String>> saveSearchHistory(List<String> queries) async {
    await prefs.setStringList(searchHistoryKey, queries);
    return queries;
  }

  Future<List<String>> addSearchQuery(
    String query, {
    int maxEntries = 20,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return loadSearchHistory();
    }

    final currentHistory = loadSearchHistory();
    final updatedHistory = <String>[
      normalizedQuery,
      ...currentHistory.where((item) => item != normalizedQuery),
    ].take(maxEntries).toList();

    return saveSearchHistory(updatedHistory);
  }

  Future<List<String>> removeSearchQuery(String query) async {
    final currentHistory = loadSearchHistory();
    final updatedHistory = currentHistory
        .where((item) => item != query)
        .toList();
    return saveSearchHistory(updatedHistory);
  }

  Future<List<String>> clearSearchHistory() async {
    return saveSearchHistory(<String>[]);
  }

  Map<String, dynamic> _toJson(Wallpaper wallpaper) {
    return {
      'id': wallpaper.id,
      'url': wallpaper.url,
      'description': wallpaper.description,
      'author': wallpaper.author,
    };
  }
}
