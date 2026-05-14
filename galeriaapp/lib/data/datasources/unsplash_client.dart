import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

    // Interceptor para manejo de errores centralizado
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

  Future<List<dynamic>> getCuratedPhotos(int page, {int perPage = 20}) async {
    final response = await dio.get(
      '/photos',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> searchPhotos(String query, int page, {int perPage = 20}) async {
    final response = await dio.get(
      '/search/photos',
      queryParameters: {'query': query, 'page': page, 'per_page': perPage},
    );
    return response.data['results'] as List<dynamic>;
  }
}
