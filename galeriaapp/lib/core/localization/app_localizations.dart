import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/wallpaper_provider.dart';

final appLocalizationsProvider = Provider<Map<String, String>>((ref) {
  final lang = ref.watch(wallpaperProvider).lang;
  return lang == 'en' ? _en : _es;
});
//aqui se define un provider de localización que devuelve un mapa de cadenas según el idioma seleccionado en el estado del proveedor de wallpapers.
//Se tienen dos mapas, uno para español y otro para inglés, con las traducciones de los textos usados en la aplicación.
const _es = {
  'search_hint': 'Buscar fondos o @autor...',
  'offline_title': 'Modo Offline',
  'offline_desc':
      'No tienes conexión a internet. Mostrando contenido en caché si está disponible.',
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
  'favorites': 'Favoritos',
  'history': 'Historial',
  'downloads': 'Descargas',
  'added_to_favorites': 'Añadido a favoritos',
  'removed_from_favorites': 'Eliminado de favoritos',
  'saved_empty': 'No hay elementos guardados en esta sección.',
  'clear_history': 'Limpiar historial',
  'remove_search_query': 'Eliminar búsqueda',
  'offline_cache_banner':
      'Sin conexión. Se muestra el contenido en caché disponible.',
  'api_error_title': 'Error de API 401',
  'api_error_desc': 'La API no está disponible. Comprueba la configuración.',
  'recent_searches': 'Búsquedas recientes',
};

const _en = {
  'search_hint': 'Search wallpapers or @author...',
  'offline_title': 'Offline Mode',
  'offline_desc':
      'No internet connection. Showing cached content if available.',
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
  'favorites': 'Favorites',
  'history': 'History',
  'downloads': 'Downloads',
  'added_to_favorites': 'Added to favorites',
  'removed_from_favorites': 'Removed from favorites',
  'saved_empty': 'There are no saved items in this section.',
  'clear_history': 'Clear history',
  'remove_search_query': 'Remove search',
  'offline_cache_banner': 'No connection. Showing available cached content.',
  'api_error_title': 'API Error 401',
  'api_error_desc': 'The API is unavailable. Check your configuration.',
  'recent_searches': 'Recent searches',
};
