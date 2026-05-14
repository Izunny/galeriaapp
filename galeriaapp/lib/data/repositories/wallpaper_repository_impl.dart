import '../../domain/entities/wallpaper.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../datasources/unsplash_client.dart';
import '../models/wallpaper_model.dart';

class WallpaperRepositoryImpl implements WallpaperRepository {
  final UnsplashClient client;

  WallpaperRepositoryImpl({required this.client});

  @override
  Future<List<Wallpaper>> getCuratedWallpapers(int page) async {
    try {
      final data = await client.getCuratedPhotos(page);
      return data.map((json) => WallpaperModel.fromJson(json)).toList();
    } catch (e) {
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
