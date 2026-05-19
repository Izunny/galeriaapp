import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/unsplash_client.dart';
import '../../data/repositories/wallpaper_repository_impl.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/repositories/wallpaper_repository.dart';
//aqui se definen los providers relacionados con los wallpapers,
//incluyendo el repositorio que interactúa con la API de Unsplash y
//el estado de los wallpapers que se muestra en la aplicación.

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});
// Este provider se encarga de proporcionar una instancia de SharedPreferences a lo largo de la aplicación,
final unsplashClientProvider = Provider<UnsplashClient>((ref) {
  return UnsplashClient();
});
// Este provider se encarga de proporcionar una instancia del cliente de Unsplash,
//que es responsable de hacer las solicitudes a la API de Unsplash para obtener los wallpapers.
final wallpaperRepositoryProvider = Provider<WallpaperRepository>((ref) {
  final client = ref.read(unsplashClientProvider);
  final prefs = ref.read(sharedPreferencesProvider);
  return WallpaperRepositoryImpl(client: client, prefs: prefs);
});

// Este provider se encarga de proporcionar una instancia del repositorio de wallpapers,
class WallpaperState {
  final List<Wallpaper> wallpapers;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final int page;
  final String query;
  final String lang;

  WallpaperState({
    this.wallpapers = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.page = 1,
    this.query = '',
    this.lang = 'es',
  });

  WallpaperState copyWith({
    List<Wallpaper>? wallpapers,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    int? page,
    String? query,
    String? lang,
  }) {
    return WallpaperState(
      wallpapers: wallpapers ?? this.wallpapers,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      query: query ?? this.query,
      lang: lang ?? this.lang,
    );
  }
}

// Este es el estado que maneja el provider de wallpapers, que incluye la lista de wallpapers,
class WallpaperNotifier extends StateNotifier<WallpaperState> {
  final WallpaperRepository repository;

  WallpaperNotifier(this.repository) : super(WallpaperState()) {
    fetchWallpapers();
  }

  Future<void> fetchWallpapers({bool reset = false}) async {
    if (state.isLoading) return;

    if (reset) {
      state = state.copyWith(page: 1, wallpapers: [], hasError: false);
    }

    state = state.copyWith(isLoading: true, hasError: false);

    try {
      List<Wallpaper> newWallpapers;
      if (state.query.isNotEmpty) {
        if (state.query.startsWith('@') && state.query.length > 1) {
          String authorQuery = state.query.substring(1).trim();

          final resolvedUsername = await repository.resolveAuthorUsername(
            authorQuery,
          );
          if (resolvedUsername == null) {
            throw Exception('Autor no encontrado para: "$authorQuery"');
          }

          newWallpapers = await repository.searchWallpapersByAuthor(
            resolvedUsername,
            state.page,
          );
        } else {
          newWallpapers = await repository.searchWallpapers(
            state.query,
            state.page,
            lang: state.lang,
          );
        }
      } else {
        newWallpapers = await repository.getCuratedWallpapers(state.page);
      }

      state = state.copyWith(
        wallpapers: [...state.wallpapers, ...newWallpapers],
        isLoading: false,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  void search(String query) {
    state = state.copyWith(query: query);
    fetchWallpapers(reset: true);
  }

  void setLanguage(String lang) {
    if (state.lang != lang) {
      state = state.copyWith(lang: lang);
      if (state.query.isNotEmpty) {
        fetchWallpapers(reset: true);
      }
    }
  }
}

final wallpaperProvider =
    StateNotifierProvider<WallpaperNotifier, WallpaperState>((ref) {
      final repository = ref.read(wallpaperRepositoryProvider);
      return WallpaperNotifier(repository);
    });
