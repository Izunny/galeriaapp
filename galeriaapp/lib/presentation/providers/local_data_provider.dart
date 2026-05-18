import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/local_storage_repository.dart';
import '../../domain/entities/wallpaper.dart';
import 'wallpaper_provider.dart';

final localStorageRepositoryProvider = Provider<LocalStorageRepository>((ref) {
  final sharedPreferences = ref.read(sharedPreferencesProvider);
  return LocalStorageRepository(sharedPreferences);
});

class LocalDataNotifier extends StateNotifier<List<Wallpaper>> {
  final LocalStorageRepository repository;
  final String storageKey;

  LocalDataNotifier(this.repository, this.storageKey)
    : super(repository.loadWallpapers(storageKey));

  bool contains(String wallpaperId) {
    return repository.containsWallpaper(storageKey, wallpaperId);
  }

  Future<void> add(Wallpaper wallpaper) async {
    state = await repository.addWallpaper(storageKey, wallpaper);
  }

  Future<void> remove(String wallpaperId) async {
    state = await repository.removeWallpaper(storageKey, wallpaperId);
  }

  Future<void> toggle(Wallpaper wallpaper) async {
    if (contains(wallpaper.id)) {
      await remove(wallpaper.id);
      return;
    }

    await add(wallpaper);
  }
}

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  final LocalStorageRepository repository;

  SearchHistoryNotifier(this.repository)
    : super(repository.loadSearchHistory());

  Future<void> add(String query) async {
    state = await repository.addSearchQuery(query);
  }

  Future<void> remove(String query) async {
    state = await repository.removeSearchQuery(query);
  }

  Future<void> clear() async {
    state = await repository.clearSearchHistory();
  }
}

final favoritesProvider =
    StateNotifierProvider<LocalDataNotifier, List<Wallpaper>>((ref) {
      final repository = ref.read(localStorageRepositoryProvider);
      return LocalDataNotifier(repository, LocalStorageRepository.favoritesKey);
    });

final downloadsProvider =
    StateNotifierProvider<LocalDataNotifier, List<Wallpaper>>((ref) {
      final repository = ref.read(localStorageRepositoryProvider);
      return LocalDataNotifier(repository, LocalStorageRepository.downloadsKey);
    });

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
      final repository = ref.read(localStorageRepositoryProvider);
      return SearchHistoryNotifier(repository);
    });
