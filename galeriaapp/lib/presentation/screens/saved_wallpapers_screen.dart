import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../core/localization/app_localizations.dart';
import '../../domain/entities/wallpaper.dart';
import '../providers/local_data_provider.dart';
import 'detail_screen.dart';

class SavedWallpapersScreen extends ConsumerWidget {
  final String title;
  final StateNotifierProvider<LocalDataNotifier, List<Wallpaper>>
  wallpapersProvider;

  const SavedWallpapersScreen({
    super.key,
    required this.title,
    required this.wallpapersProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallpapers = ref.watch(wallpapersProvider);
    final loc = ref.watch(appLocalizationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: wallpapers.isEmpty
          ? Center(
              child: Text(
                loc['saved_empty']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(wallpapersProvider);
              },
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                padding: const EdgeInsets.all(8),
                itemCount: wallpapers.length,
                itemBuilder: (context, index) {
                  final wallpaper = wallpapers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailScreen(wallpaper: wallpaper),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Hero(
                            tag: wallpaper.id,
                            child: CachedNetworkImage(
                              imageUrl: wallpaper.url,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 200,
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
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
                                    const Color.fromRGBO(0, 0, 0, 0.7),
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
            ),
    );
  }
}
