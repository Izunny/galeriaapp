import '../../domain/entities/wallpaper.dart';

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
      description: json['description'] ?? json['alt_description'] ?? 'No description',
      author: json['user']?['name'] ?? 'Unknown',
    );
  }
}
