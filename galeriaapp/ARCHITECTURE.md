# Arquitectura Técnica - GaleriaApp

## 📐 Diagrama General

```
┌─────────────────────────────────────────────┐
│        PRESENTATION LAYER (UI/UX)          │
│  ┌─────────────────────────────────────┐   │
│  │  Screens + Widgets + Localization   │   │
│  │  - HomeScreen (search + grid)       │   │
│  │  - DetailScreen (favoritos + dl)    │   │
│  │  - FullscreenImageScreen (zoom)     │   │
│  │  - SavedWallpapersScreen (fav/dl)   │   │
│  │  - SearchHistoryScreen              │   │
│  └─────────────────────────────────────┘   │
│              ↓ (Riverpod)                   │
│  ┌─────────────────────────────────────┐   │
│  │   STATE MANAGEMENT (Riverpod)       │   │
│  │  - wallpaperProvider                │   │
│  │  - favoritesProvider                │   │
│  │  - downloadsProvider                │   │
│  │  - searchHistoryProvider            │   │
│  │  - themeProvider                    │   │
│  │  - networkStatusProvider            │   │
│  └─────────────────────────────────────┘   │
└──────────────────┬──────────────────────────┘
                   │
      ┌────────────┴────────────┐
      ↓                         ↓
┌─────────────────────┐  ┌──────────────────┐
│  DOMAIN LAYER       │  │  DATA LAYER      │
│  (Lógica Negocio)   │  │  (Persistence)   │
│  ┌───────────────┐  │  │ ┌──────────────┐ │
│  │   Wallpaper   │  │  │ │ Repositories │ │
│  │   (Entity)    │  │  │ │ - Wallpaper  │ │
│  └───────────────┘  │  │ │ - LocalData  │ │
│                     │  │ └──────────────┘ │
└─────────────────────┘  │ ┌──────────────┐ │
                         │ │  Datasources │ │
                         │ │ - Unsplash   │ │
                         │ └──────────────┘ │
                         │ ┌──────────────┐ │
                         │ │   Models     │ │
                         │ │ - WallpaperM │ │
                         │ └──────────────┘ │
                         └──────────────────┘
                                ↓
                    ┌─────────────────────┐
                    │  EXTERNAL SERVICES  │
                    │  - SharedPrefs      │
                    │  - Unsplash API     │
                    │  - Device Storage   │
                    │  - Connectivity     │
                    └─────────────────────┘
```

---

## 🔄 Flujo de Datos: Búsqueda de Wallpapers

```
1. USER INTERACTION
   └─ TextField en HomeScreen onSubmitted

2. STATE UPDATE
   └─ wallpaperProvider.notifier.search(query)
      ├─ Resetea página a 0
      ├─ Agrega query a searchHistoryProvider
      └─ Dispara fetchWallpapers()

3. REPOSITORY LAYER
   └─ wallpaperRepositoryProvider.searchWallpapers(query)
      ├─ Intenta: UnsplashClient.search(query)
      ├─ Éxito: Cachea en SharedPreferences
      │         WallpaperModel.toJson() → prefs.setString()
      └─ Error: Intenta cargar del cache

4. STATE MANAGEMENT
   └─ WallpaperNotifier.fetchWallpapers()
      ├─ setState: isLoading = true
      ├─ Llama repository.searchWallpapers()
      ├─ append resultados a list (infinito scroll)
      └─ setState: isLoading = false

5. UI REBUILD
   └─ WallpaperGrid.build()
      ├─ ref.watch(wallpaperProvider)
      ├─ Construye MasonryGridView con items
      └─ Actualiza display
```

---

## 💾 Persistencia: Stack de Almacenamiento

### 1. **SharedPreferences** (Local Storage)
```dart
// Favoritos
prefs.setString('favorites', jsonEncode(wallpaperList))
prefs.getString('favorites') → deserialization

// Descargas
prefs.setString('downloads', jsonEncode(wallpaperList))

// Historial
prefs.setString('search_history', jsonEncode(queryList))

// Cache de búsquedas
prefs.setString('cached_search_es_nature', jsonEncode(results))
prefs.setString('cached_author_john_doe', jsonEncode(results))
prefs.setString('cached_wallpapers', jsonEncode(curated))
```

### 2. **Device Gallery** (via image_gallery_saver_plus)
```dart
// Post-descarga
ImageGallerySaverPlus.saveFile(filePath)
└─ Guarda en galería del dispositivo (automático)
```

### 3. **Caché de Imágenes** (cached_network_image)
```dart
CachedNetworkImage(imageUrl, ...)
└─ Flutter cache de imágenes en memoria + disco automático
```

---

## 🎯 Requisitos Mapeados a Código

### Requisito 1: Favoritos
```
📁 lib/presentation/providers/local_data_provider.dart
   └─ LocalDataNotifier(StateNotifier<List<Wallpaper>>)
      ├─ toggle(wallpaper) → add/remove
      ├─ contains(id) → check if favorite
      └─ favoritesProvider exposición al UI

📁 lib/data/repositories/local_storage_repository.dart
   └─ addWallpaper(id, 'favorites') → persist
      └─ saveWallpapers(List<Wallpaper>) → JSON encode

📁 lib/presentation/screens/detail_screen.dart
   └─ IconButton con onPressed → ref.read(favoritesProvider.notifier).toggle()
```

### Requisito 2: Historial de Búsquedas
```
📁 lib/presentation/providers/local_data_provider.dart
   └─ SearchHistoryNotifier(StateNotifier<List<String>>)
      ├─ addSearchQuery(query) → append + save
      ├─ removeSearchQuery(query) → remove
      ├─ clearSearchHistory() → clear all
      └─ searchHistoryProvider exposición al UI

📁 lib/presentation/screens/home_screen.dart
   └─ onSubmitted(query) → ref.read(searchHistoryProvider.notifier).addSearchQuery(query)

📁 lib/presentation/screens/search_history_screen.dart
   └─ ListView.builder(searchHistoryProvider.watch())
      ├─ ListTile con query
      ├─ Delete button → removeSearchQuery
      └─ Clear all button → clearSearchHistory
```

### Requisito 3: Descargas
```
📁 lib/presentation/screens/detail_screen.dart
   └─ FloatingActionButton → _downloadImage()
      ├─ trackDownload(id) en API
      ├─ Dio().download(url, tempPath)
      ├─ ImageGallerySaverPlus.saveFile(tempPath)
      └─ ref.read(downloadsProvider.notifier).add(wallpaper)

📁 lib/presentation/providers/local_data_provider.dart
   └─ LocalDataNotifier.add(wallpaper)
      ├─ Append a lista
      └─ Persist via localStorageRepository
```

### Requisito 4: Cache Offline
```
📁 lib/data/repositories/wallpaper_repository_impl.dart
   └─ searchWallpapers(query) {
      try {
        api.search(query) → success
        _saveCache(key, results)
        return results
      } catch {
        _loadCache(key) → fallback
        return cached ?: empty
      }
   }

📁 lib/presentation/providers/network_provider.dart
   └─ networkStatusProvider = StreamProvider
      └─ connectivity_plus.onConnectivityChanged

📁 lib/presentation/screens/home_screen.dart
   └─ if (networkStatus == ConnectivityResult.none)
      └─ Show orange banner: "Sin conexión..."

   ### Requisito 4.1: Manejo de Errores API / 401

   ```
   📁 lib/presentation/widgets/wallpaper_grid.dart
      └─ Al recibir `state.hasError == true`, inspecciona `state.errorMessage`.
         ├─ Si contiene `401`, `unauthorized` o `client_id` → muestra `ErrorScreen`.
         └─ `ErrorScreen` (lib/presentation/screens/error_screen.dart) muestra una ilustración local `assets/images/sad_cat.png`, texto localizado y botón `Reintentar`.

   Rationale: brindar feedback visual claro cuando la API rechaza la petición (clave inválida/limite) y ofrecer acción inmediata de reintento.
   ```
```

### Requisito 5: Recent Searches UI
```
📁 lib/presentation/screens/home_screen.dart
   └─ Body Column con:
      ├─ SearchTextField
      └─ if (searchHistory.isNotEmpty)
         └─ ActionChip.builder(searchHistory.watch())
            ├─ Mostrar últimas búsquedas
            └─ onPressed → populate field + search
```

### Requisito 6: Double-Tap Zoom
```
📁 lib/presentation/screens/detail_screen.dart
   └─ GestureDetector(onDoubleTap)
      └─ Navigator.push(FullscreenImageScreen)

📁 lib/presentation/screens/fullscreen_image_screen.dart
   ├─ InteractiveViewer(transformationController)
   │  ├─ panEnabled: true
   │  ├─ scaleEnabled: true
   │  ├─ minScale: 1.0, maxScale: 4.0
   │  └─ Child: Hero + CachedNetworkImage
   │
   ├─ GestureDetector(onDoubleTap)
   │  └─ _toggleZoom() → 2.5x scale toggle
   │
   └─ PageRouteBuilder
      └─ Duration: 180ms fade transition
```

---

## 🔌 Inyección de Dependencias (Riverpod)

### Providers Principales

```dart
// Repositories
final wallpaperRepositoryProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WallpaperRepositoryImpl(client, prefs);
});

final localStorageRepositoryProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageRepository(prefs);
});

// State Notifiers
final wallpaperProvider = StateNotifierProvider((ref) {
  final repo = ref.watch(wallpaperRepositoryProvider);
  return WallpaperNotifier(repo);
});

final favoritesProvider = StateNotifierProvider((ref) {
  final repo = ref.watch(localStorageRepositoryProvider);
  return LocalDataNotifier(repo, 'favorites');
});

// Streams
final networkStatusProvider = StreamProvider((ref) {
  return Connectivity().onConnectivityChanged;
});
```

---

## 🎨 UI State Management Flow

```
┌─ ConsumerWidget watches provider
│  └─ ref.watch(wallpaperProvider)
│
├─ Provider emits state change
│  └─ StateNotifier.setState() → notifyListeners()
│
└─ Widget rebuilds automáticamente
   └─ build(context, ref) called again
```

---

## 📊 Base de Datos: SharedPreferences Schema

```
{
  "favorites": [
    { "id": "abc123", "url": "...", "author": "...", ... },
    ...
  ],
  
  "downloads": [
    { "id": "xyz789", "url": "...", "author": "...", ... },
    ...
  ],
  
  "search_history": ["nature", "sunset", "mountains"],
  
  "cached_search_es_nature": [
    { "id": "....", "url": "...", ... },
    ...
  ],
  
  "cached_author_john_doe": [
    { "id": "....", "url": "...", ... },
    ...
  ],
  
  "cached_wallpapers": [
    { "id": "....", "url": "...", ... },
    ...
  ],
  
  "isDarkMode": true,
  "appLanguage": "es"
}
```

---

## ⚙️ Lifecycle: App Start

```
1. main.dart
   ├─ WidgetsFlutterBinding.ensureInitialized()
   ├─ dotenv.load(".env")
   ├─ SharedPreferences.getInstance()
   ├─ ProviderScope override sharedPreferencesProvider
   └─ runApp(MainApp)

2. MainApp.build()
   ├─ ref.watch(themeProvider) → MaterialApp.themeMode
   ├─ home: SplashScreen → HomeScreen

3. HomeScreen.build()
   ├─ ref.watch(wallpaperProvider) → initial load
   ├─ ref.watch(networkStatusProvider) → conexión
   ├─ ref.watch(searchHistoryProvider) → recent chips
   └─ render grid + drawer
```

---

## 🧪 Testing Puntos

- Unit tests para `LocalStorageRepository.addWallpaper()`
- Unit tests para `SearchHistoryNotifier.addSearchQuery()`
- Widget tests para `WallpaperGrid` offline banner
- Integration tests para flujo completo (search → favorite → detail → zoom)

---

## 📈 Performance Optimizations

1. **Lazy Loading**: `WallpaperGrid` scroll listener → `ref.read(wallpaperProvider.notifier).fetchWallpapers()`
2. **Caché Multi-Nivel**: SharedPreferences (persistente) + cached_network_image (RAM + disk)
3. **Riverpod selectors**: `ref.watch(wallpaperProvider.select((state) => state.isLoading))`
4. **Hero Animations**: Transición suave entre DetailScreen ↔ FullscreenImageScreen
5. **Network aware**: Connectivity stream chequea antes de hacer requests

---

## 🛡️ Error Handling

```dart
try {
  final results = await repository.searchWallpapers(query);
  state = state.copyWith(wallpapers: results, hasError: false);
} catch (e) {
  final cached = await repository._loadCache(key);
  if (cached != null) {
   ├─ InteractiveViewer(transformationController)
   │  ├─ panEnabled: true
   │  ├─ scaleEnabled: true
   │  ├─ minScale: 1.0, maxScale: 4.0
   │  └─ Child: Hero + CachedNetworkImage
```

---
   └─ PageRouteBuilder
      └─ transitionDuration: 180ms (fade) / reverse: 140ms (fade)
