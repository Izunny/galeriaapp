import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/localization/app_localizations.dart';
import '../screens/error_screen.dart';
import '../providers/wallpaper_provider.dart';
import '../screens/detail_screen.dart';

class WallpaperGrid extends ConsumerStatefulWidget {
  const WallpaperGrid({super.key});

  @override
  ConsumerState<WallpaperGrid> createState() => _WallpaperGridState();
}

class _WallpaperGridState extends ConsumerState<WallpaperGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(wallpaperProvider.notifier).fetchWallpapers();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wallpaperProvider);
    final loc = ref.watch(appLocalizationsProvider);

    if (state.wallpapers.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.wallpapers.isEmpty && state.hasError) {
      final errorMsg = state.errorMessage.toLowerCase();
      final isUnauthorized =
          errorMsg.contains('401') ||
          errorMsg.contains('unauthorized') ||
          errorMsg.contains('client_id');

      final networkKeywords = [
        'socketexception',
        'failed host lookup',
        'no internet',
        'network',
        'connect',
        'handshakeexception',
        'network is unreachable',
        'dnslookup',
        'timed out',
        'dioerror',
        'connection refused',
        'connection timed out',
      ];
      final isNetworkError = networkKeywords.any((k) => errorMsg.contains(k));

      if (isUnauthorized) {
        return Center(
          child: ErrorScreen(
            title: loc['api_error_title'] ?? 'API Error',
            message: loc['api_error_desc'] ?? state.errorMessage,
            retryLabel: loc['retry'],
            onRetry: () => ref
                .read(wallpaperProvider.notifier)
                .fetchWallpapers(reset: true),
          ),
        );
      }

      if (isNetworkError) {
        return Center(
          child: ErrorScreen(
            title: loc['offline_title'] ?? 'Offline',
            message: loc['offline_desc'] ?? 'No tienes conexión a internet.',
            retryLabel: loc['retry'],
            onRetry: () => ref
                .read(wallpaperProvider.notifier)
                .fetchWallpapers(reset: true),
          ),
        );
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(wallpaperProvider.notifier)
                  .fetchWallpapers(reset: true),
              child: Text(loc['retry']!),
            ),
          ],
        ),
      );
    }

    if (state.wallpapers.isEmpty && !state.isLoading) {
      return Center(child: Text(loc['no_wallpapers']!));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(wallpaperProvider.notifier).fetchWallpapers(reset: true);
      },
      child: MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.all(8),
        itemCount: state.wallpapers.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.wallpapers.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final wallpaper = state.wallpapers[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(wallpaper: wallpaper),
                ),
              );
            },
            child: ClipRidge(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Hero(
                    tag: wallpaper.id,
                    child: CachedNetworkImage(
                      imageUrl: wallpaper.url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200, // Altura por defecto mientras carga
                        color: Colors.grey.shade300,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        wallpaper.author,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ClipRidge extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const ClipRidge({super.key, required this.child, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: borderRadius, child: child);
  }
}
