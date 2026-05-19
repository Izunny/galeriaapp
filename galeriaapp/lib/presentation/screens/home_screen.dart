import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/local_data_provider.dart';
import '../providers/network_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/wallpaper_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../widgets/wallpaper_grid.dart';
import 'search_history_screen.dart';
import 'saved_wallpapers_screen.dart';
import 'error_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

//aqui se implementa la pantalla principal de la aplicación, que incluye un buscador, un menú lateral para acceder a favoritos, historial y descargas, y muestra una cuadrícula de wallpapers. También maneja el estado de la conexión a internet para mostrar un banner de advertencia o una pantalla de error personalizada en caso de problemas de red.
class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final networkStatus = ref.watch(networkStatusProvider);
    final themeMode = ref.watch(themeProvider);
    final currentLang = ref.watch(wallpaperProvider).lang;
    final loc = ref.watch(appLocalizationsProvider);
    final recentSearches = ref.watch(searchHistoryProvider);
    // aqui se construye la interfaz de usuario, incluyendo el AppBar con el buscador y los botones de configuración,
    //el Drawer para navegación, y el cuerpo que muestra la cuadrícula de wallpapers
    //o mensajes de error según el estado de la conexión a internet y los datos disponibles.
    return Scaffold(
      drawer: Drawer(
        width: 200,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: themeMode == ThemeMode.dark
                    ? const Color.fromARGB(255, 100, 40, 95)
                    : Colors.blue.shade700,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset('assets/images/icon.png', height: 64, width: 64),
                  const SizedBox(height: 10),
                  const Text(
                    'GaleríaApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: Text(loc['favorites']!),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavedWallpapersScreen(
                      title: loc['favorites']!,
                      wallpapersProvider: favoritesProvider,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(loc['history']!),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchHistoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_done),
              title: Text(loc['downloads']!),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavedWallpapersScreen(
                      title: loc['downloads']!,
                      wallpapersProvider: downloadsProvider,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        // aqui se configura el AppBar con el título, el botón de cambio de idioma, el botón de cambio de tema, y un TextField para realizar búsquedas de wallpapers.
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/icon.png', height: 32, width: 32),
            const SizedBox(width: 8),
            const Text(
              'GaleríaApp',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            initialValue: currentLang,
            icon: const Icon(Icons.language),
            tooltip: loc['change_lang'],
            onSelected: (String lang) {
              ref.read(wallpaperProvider.notifier).setLanguage(lang);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'es', child: Text(loc['spanish']!)),
              PopupMenuItem<String>(value: 'en', child: Text(loc['english']!)),
            ],
          ),
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc['search_hint'],
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(wallpaperProvider.notifier).search('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  final query = value.trim();
                  ref.read(searchHistoryProvider.notifier).add(query);
                  ref.read(wallpaperProvider.notifier).search(query);
                }
              },
            ),
          ),
        ),
      ),
      body: networkStatus.when(
        //aqui se maneja el estado de la conexión a internet para mostrar un banner de advertencia
        data: (status) {
          return Column(
            children: [
              if (status.contains(ConnectivityResult.none))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.orange.shade700,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              loc['offline_cache_banner']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (recentSearches.isNotEmpty)
                Padding(
                  //aqui se muestra una sección de "Búsquedas recientes" debajo del banner de advertencia si el usuario ha realizado búsquedas anteriormente
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc['recent_searches']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: recentSearches.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final query = recentSearches[index];
                              return ActionChip(
                                label: Text(query),
                                avatar: const Icon(Icons.history, size: 18),
                                onPressed: () {
                                  _searchController.text = query;
                                  _searchController.selection =
                                      TextSelection.fromPosition(
                                        TextPosition(offset: query.length),
                                      );
                                  ref
                                      .read(searchHistoryProvider.notifier)
                                      .add(query);
                                  ref
                                      .read(wallpaperProvider.notifier)
                                      .search(query);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Expanded(child: WallpaperGrid()),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(
          child: ErrorScreen(
            title: loc['offline_title'] ?? 'Error',
            message: loc['offline_desc'] ?? e.toString(),
            retryLabel: loc['retry'],
            onRetry: () {
              ref.read(wallpaperProvider.notifier).fetchWallpapers(reset: true);
            },
          ),
        ),
      ),
    );
  }
}
