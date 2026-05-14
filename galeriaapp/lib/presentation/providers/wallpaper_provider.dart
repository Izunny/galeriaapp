import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/unsplash_client.dart';
import '../../data/repositories/wallpaper_repository_impl.dart';
import '../../domain/entities/wallpaper.dart';
import '../../domain/repositories/wallpaper_repository.dart';

final unsplashClientProvider = Provider<UnsplashClient>((ref) {
  return UnsplashClient();
});

final wallpaperRepositoryProvider = Provider<WallpaperRepository>((ref) {
  final client = ref.read(unsplashClientProvider);
  return WallpaperRepositoryImpl(client: client);
});

class WallpaperState {
  final List<Wallpaper> wallpapers;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final int page;
  final String query;

  WallpaperState({
    this.wallpapers = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
    this.page = 1,
    this.query = '',
  });

  WallpaperState copyWith({
    List<Wallpaper>? wallpapers,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    int? page,
    String? query,
  }) {
    return WallpaperState(
      wallpapers: wallpapers ?? this.wallpapers,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      query: query ?? this.query,
    );
  }
}

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
        newWallpapers = await repository.searchWallpapers(state.query, state.page);
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
}

final wallpaperProvider = StateNotifierProvider<WallpaperNotifier, WallpaperState>((ref) {
  final repository = ref.read(wallpaperRepositoryProvider);
  return WallpaperNotifier(repository);
});
