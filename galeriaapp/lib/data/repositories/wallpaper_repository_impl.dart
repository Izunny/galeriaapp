import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../datasources/unsplash_client.dart';
import '../models/wallpaper_model.dart';

class WallpaperRepositoryImpl implements WallpaperRepository {
  final UnsplashClient client;
  final SharedPreferences prefs;

  WallpaperRepositoryImpl({required this.client, required this.prefs});

  @override
  Future<List<Wallpaper>> getCuratedWallpapers(int page) async {
    try {
      final data = await client.getCuratedPhotos(page);
      final wallpapers = data.map((json) => WallpaperModel.fromJson(json)).toList();

      // Cache the first page for offline use
      if (page == 1) {
        final cachedData = wallpapers.map((w) => w.toJson()).toList();
        await prefs.setString('cached_wallpapers', jsonEncode(cachedData));
      }

      return wallpapers;
    } catch (e) {
      // Fallback to cache if available
      if (page == 1) {
        final cachedString = prefs.getString('cached_wallpapers');
        if (cachedString != null) {
          final List<dynamic> cachedJson = jsonDecode(cachedString);
          return cachedJson.map((json) => WallpaperModel.fromCacheJson(json)).toList();
        }
      }
      throw Exception('Failed to load curated wallpapers: $e');
    }
  }

  @override
  Future<List<Wallpaper>> searchWallpapers(String query, int page) async {
    try {
      final data = await client.searchPhotos(query, page);
      return data.map((json) => WallpaperModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search wallpapers: $e');
    }
  }
}
