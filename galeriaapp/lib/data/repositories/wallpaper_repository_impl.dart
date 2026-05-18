import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../datasources/unsplash_client.dart';
import '../models/wallpaper_model.dart';

class WallpaperRepositoryImpl implements WallpaperRepository {
  static const String _cachedCuratedKey = 'cached_wallpapers';
  final UnsplashClient client;
  final SharedPreferences prefs;

  WallpaperRepositoryImpl({required this.client, required this.prefs});

  String _cacheKeyForCurated() => _cachedCuratedKey;

  String _cacheKeyForSearch(String query, String lang) {
    return 'cached_search_${lang}_${query.trim().toLowerCase()}';
  }

  String _cacheKeyForAuthor(String username) {
    return 'cached_author_${username.trim().toLowerCase()}';
  }

  Future<void> _saveCache(String key, List<Wallpaper> wallpapers) async {
    final cachedData = wallpapers
        .map(
          (w) => {
            'id': w.id,
            'url': w.url,
            'description': w.description,
            'author': w.author,
          },
        )
        .toList();
    await prefs.setString(key, jsonEncode(cachedData));
  }

  List<Wallpaper>? _loadCache(String key) {
    final cachedString = prefs.getString(key);
    if (cachedString == null) {
      return null;
    }

    final List<dynamic> cachedJson = jsonDecode(cachedString);
    return cachedJson
        .map((json) => WallpaperModel.fromCacheJson(json))
        .toList();
  }

  @override
  Future<List<Wallpaper>> getCuratedWallpapers(int page) async {
    try {
      final data = await client.getCuratedPhotos(page);
      final wallpapers = data
          .map((json) => WallpaperModel.fromJson(json))
          .toList();

      // Cache the first page for offline use
      if (page == 1) {
        await _saveCache(_cacheKeyForCurated(), wallpapers);
      }

      return wallpapers;
    } catch (e) {
      // Fallback to cache if available
      if (page == 1) {
        final cachedWallpapers = _loadCache(_cacheKeyForCurated());
        if (cachedWallpapers != null) {
          return cachedWallpapers;
        }
      }
      throw Exception('No se pudo cargar fondos de pantalla: $e');
    }
  }

  @override
  Future<List<Wallpaper>> searchWallpapers(
    String query,
    int page, {
    String lang = 'es',
  }) async {
    try {
      final data = await client.searchPhotos(query, page, lang: lang);
      final wallpapers = data
          .map((json) => WallpaperModel.fromJson(json))
          .toList();

      if (page == 1) {
        await _saveCache(_cacheKeyForSearch(query, lang), wallpapers);
      }

      return wallpapers;
    } catch (e) {
      if (page == 1) {
        final cachedWallpapers = _loadCache(_cacheKeyForSearch(query, lang));
        if (cachedWallpapers != null) {
          return cachedWallpapers;
        }
      }
      throw Exception('No se pudo buscar fondos de pantalla: $e');
    }
  }

  @override
  Future<String?> resolveAuthorUsername(String query) async {
    return await client.searchUserUsername(query);
  }

  @override
  Future<List<Wallpaper>> searchWallpapersByAuthor(
    String username,
    int page,
  ) async {
    try {
      final data = await client.getUserPhotos(username, page);
      final wallpapers = data
          .map((json) => WallpaperModel.fromJson(json))
          .toList();

      if (page == 1) {
        await _saveCache(_cacheKeyForAuthor(username), wallpapers);
      }

      return wallpapers;
    } catch (e) {
      if (page == 1) {
        final cachedWallpapers = _loadCache(_cacheKeyForAuthor(username));
        if (cachedWallpapers != null) {
          return cachedWallpapers;
        }
      }
      throw Exception('Usuario sin fotos o no encontrado: $e');
    }
  }

  @override
  Future<String> trackDownload(String photoId) async {
    try {
      return await client.trackDownload(photoId);
    } catch (e) {
      throw Exception('Error al descargar la imagen: $e');
    }
  }
}
