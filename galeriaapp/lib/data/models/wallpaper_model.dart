import '../../domain/entities/wallpaper.dart';

// Este modelo extiende la clase Wallpaper definida en el dominio,
// y se encarga de convertir los datos JSON obtenidos de la API de Unsplash en objetos
class WallpaperModel extends Wallpaper {
  WallpaperModel({
    required super.id,
    required super.url,
    required super.description,
    required super.author,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'] ?? '',
      url: json['urls']?['regular'] ?? '',
      description:
          json['description'] ?? json['alt_description'] ?? 'No description',
      author: json['user']?['name'] ?? 'Unknown',
    );
  }

  factory WallpaperModel.fromCacheJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'] as String,
      url: json['url'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'description': description, 'author': author};
  }
}
