import '../entities/wallpaper.dart';

abstract class WallpaperRepository {
  // Definimos qué puede hacer nuestra app, sin decir cómo lo hace aún
  // Esto es lo que el resto de la app va a usar para interactuar con los wallpapers,
  // sin importar si vienen de la API, de la caché local, o de cualquier otra fuente.
  Future<List<Wallpaper>> getCuratedWallpapers(int page);
  Future<List<Wallpaper>> searchWallpapers(
    String query,
    int page, {
    String lang = 'es',
  });
  Future<String?> resolveAuthorUsername(String query);
  Future<List<Wallpaper>> searchWallpapersByAuthor(String username, int page);
  Future<String> trackDownload(String photoId);
}
