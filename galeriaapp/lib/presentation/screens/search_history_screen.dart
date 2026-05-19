import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../providers/local_data_provider.dart';
import '../providers/wallpaper_provider.dart';

class SearchHistoryScreen extends ConsumerWidget {
  const SearchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searches = ref.watch(searchHistoryProvider);
    final loc = ref.watch(appLocalizationsProvider);
    // Esta pantalla muestra el historial de búsquedas del usuario.
    //Si no hay búsquedas, muestra un mensaje indicando que el historial está vacío. Si hay búsquedas,
    //las muestra en una lista con la opción de eliminar cada búsqueda individualmente
    return Scaffold(
      appBar: AppBar(
        title: Text(loc['history']!),
        centerTitle: true,
        actions: [
          if (searches.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: loc['clear_history'],
              onPressed: () async {
                await ref.read(searchHistoryProvider.notifier).clear();
              },
            ),
        ],
      ),
      body: searches.isEmpty
          ? Center(
              child: Text(
                loc['saved_empty']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: searches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final query = searches[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.search),
                    title: Text(query),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: loc['remove_search_query'],
                      onPressed: () async {
                        await ref
                            .read(searchHistoryProvider.notifier)
                            .remove(query);
                      },
                    ),
                    onTap: () {
                      ref.read(wallpaperProvider.notifier).search(query);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
    );
  }
}
