import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/wallpaper.dart';
import '../../core/localization/app_localizations.dart';
import '../providers/local_data_provider.dart';
import '../providers/wallpaper_provider.dart';
import 'fullscreen_image_screen.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Wallpaper wallpaper;

  const DetailScreen({super.key, required this.wallpaper});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _downloadImage(Map<String, String> loc) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final repository = ref.read(wallpaperRepositoryProvider);

      // 1. Obtener URL de alta calidad y registrar la descarga en la API
      final downloadUrl = await repository.trackDownload(widget.wallpaper.id);

      // 2. Descargar imagen a carpeta temporal
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/${widget.wallpaper.id}.jpg';

      await Dio().download(downloadUrl, tempPath);

      // 3. Guardar en galería
      final result = await ImageGallerySaverPlus.saveFile(tempPath);
      final isSuccess = result['isSuccess'] == true;

      if (isSuccess) {
        await ref.read(downloadsProvider.notifier).add(widget.wallpaper);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSuccess ? loc['download_success']! : loc['download_error']!,
            ),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc['download_error']!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(appLocalizationsProvider);
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.any((item) => item.id == widget.wallpaper.id);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.redAccent : Colors.white,
            ),
            onPressed: () async {
              final favoritesNotifier = ref.read(favoritesProvider.notifier);
              final wasFavorite = favoritesNotifier.contains(
                widget.wallpaper.id,
              );

              await favoritesNotifier.toggle(widget.wallpaper);

              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    wasFavorite
                        ? loc['removed_from_favorites']!
                        : loc['added_to_favorites']!,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onDoubleTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FullscreenImageScreen(
                        imageUrl: widget.wallpaper.url,
                        tag: widget.wallpaper.id,
                      ),
                  transitionDuration: const Duration(milliseconds: 180),
                  reverseTransitionDuration: const Duration(milliseconds: 140),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                ),
              );
            },
            child: Hero(
              tag: widget.wallpaper.id,
              child: CachedNetworkImage(
                imageUrl: widget.wallpaper.url,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error, color: Colors.red)),
              ),
            ),
          ),

          // Gradient Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color.fromRGBO(0, 0, 0, 0.9),
                    const Color.fromRGBO(0, 0, 0, 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.wallpaper.author,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.wallpaper.description.isNotEmpty)
                    Text(
                      widget.wallpaper.description == 'No description'
                          ? loc['no_description']!
                          : widget.wallpaper.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isDownloading ? null : () => _downloadImage(loc),
        tooltip: loc['download_tooltip'],
        child: _isDownloading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.download),
      ),
    );
  }
}
