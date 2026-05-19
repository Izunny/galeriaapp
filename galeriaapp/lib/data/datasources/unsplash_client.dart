import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Esta clase es un cliente HTTP personalizado para interactuar con la API de Unsplash,
class UnsplashClient {
  late Dio dio;

  UnsplashClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.unsplash.com/',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        // Agregamos el header de autorización globalmente
        headers: {
          'Authorization': 'Client-ID ${dotenv.env['UNSPLASH_ACCESS_KEY']}',
          'Accept-Version': 'v1',
        },
      ),
    );

    // Interceptor para manejo de errores
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          print("Dio Error: ${e.message}");
          if (e.response != null) {
            print("Status Code: ${e.response?.statusCode}");
            print("Response Data: ${e.response?.data}");
          }
          if (e.type == DioExceptionType.connectionError) {
            print("Error de conexión detectado en Dio");
          }
          return handler.next(e);
        },
      ),
    );
  }
  // y se encarga de hacer las solicitudes a la API de Unsplash para obtener los wallpapers,
  Future<List<dynamic>> getCuratedPhotos(int page, {int perPage = 20}) async {
    final response = await dio.get(
      '/photos',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return response.data as List<dynamic>;
  }

  // También incluye métodos para buscar fotos por consulta, obtener fotos de un usuario específico,
  //resolver el nombre de usuario de un autor a partir de una consulta, y rastrear las descargas de fotos,
  //todo utilizando los endpoints correspondientes de la API de Unsplash.
  Future<List<dynamic>> searchPhotos(
    String query,
    int page, {
    int perPage = 20,
    String lang = 'es',
  }) async {
    final response = await dio.get(
      '/search/photos',
      queryParameters: {
        'query': query,
        'page': page,
        'per_page': perPage,
        'lang': lang, // Idioma seleccionado por el usuario
      },
    );
    return response.data['results'] as List<dynamic>;
  }

  // Este método realiza una búsqueda de fotos en Unsplash utilizando la consulta proporcionada, el número de página,
  Future<List<dynamic>> getUserPhotos(
    String username,
    int page, {
    int perPage = 20,
  }) async {
    final response = await dio.get(
      '/users/$username/photos',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return response.data as List<dynamic>;
  }

  // Este método obtiene las fotos de un usuario específico en Unsplash utilizando su nombre de usuario y el número de página.
  Future<String?> searchUserUsername(String query) async {
    try {
      final response = await dio.get(
        '/search/users',
        queryParameters: {'query': query, 'per_page': 1},
      );
      final results = response.data['results'] as List<dynamic>;
      if (results.isNotEmpty) {
        return results.first['username'] as String;
      }
    } catch (e) {
      print("Error resolving user: $e");
    }
    return null;
  }

  Future<String> trackDownload(String photoId) async {
    final response = await dio.get('/photos/$photoId/download');
    return response.data['url'] as String;
  }
}
