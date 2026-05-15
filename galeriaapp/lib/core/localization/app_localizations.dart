import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/wallpaper_provider.dart';

final appLocalizationsProvider = Provider<Map<String, String>>((ref) {
  final lang = ref.watch(wallpaperProvider).lang;
  return lang == 'en' ? _en : _es;
});

const _es = {
  'search_hint': 'Buscar fondos o @autor...',
  'offline_title': 'Modo Offline',
  'offline_desc': 'No tienes conexión a internet. Mostrando contenido en caché si está disponible.',
  'retry': 'Reintentar',
  'change_lang': 'Cambiar idioma',
  'spanish': 'Español',
  'english': 'English',
  'no_wallpapers': 'No se encontraron fondos.',
  'no_description': 'Sin descripción',
  'downloading': 'Descargando...',
  'download_success': 'Imagen descargada con éxito',
  'download_error': 'Error al descargar la imagen',
  'download_tooltip': 'Descargar imagen',
};

const _en = {
  'search_hint': 'Search wallpapers or @author...',
  'offline_title': 'Offline Mode',
  'offline_desc': 'No internet connection. Showing cached content if available.',
  'retry': 'Retry',
  'change_lang': 'Change language',
  'spanish': 'Spanish',
  'english': 'English',
  'no_wallpapers': 'No wallpapers found.',
  'no_description': 'No description',
  'downloading': 'Downloading...',
  'download_success': 'Image downloaded successfully',
  'download_error': 'Failed to download image',
  'download_tooltip': 'Download image',
};
