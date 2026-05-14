import '../entities/wallpaper.dart';

abstract class WallpaperRepository {
  // Definimos qué puede hacer nuestra app, sin decir cómo lo hace aún
  Future<List<Wallpaper>> getCuratedWallpapers(int page);
  Future<List<Wallpaper>> searchWallpapers(String query, int page);
}
