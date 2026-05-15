import '../entities/wallpaper.dart';

abstract class WallpaperRepository {
  // Definimos qué puede hacer nuestra app, sin decir cómo lo hace aún
  Future<List<Wallpaper>> getCuratedWallpapers(int page);
  Future<List<Wallpaper>> searchWallpapers(String query, int page, {String lang = 'es'});
  Future<String?> resolveAuthorUsername(String query);
  Future<List<Wallpaper>> searchWallpapersByAuthor(String username, int page);
  Future<String> trackDownload(String photoId);
}
