import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/network_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/wallpaper_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsplash Wallpapers', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search wallpapers...',
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
                  ref.read(wallpaperProvider.notifier).search(value.trim());
                }
              },
            ),
          ),
        ),
      ),
      body: networkStatus.when(
        data: (status) {
          if (status.contains(ConnectivityResult.none)) {
            return _buildNoConnectionWidget();
          }
          return const WallpaperGrid();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildNoConnectionWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.signal_wifi_connected_no_internet_4, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Modo Offline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Text(
              'No tienes conexión a internet. Mostrando contenido en caché si está disponible.',
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Simular reintento de conexión
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
