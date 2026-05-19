[README.md](https://github.com/user-attachments/files/28023048/README.md)
# GaleriaApp - Wallpaper Gallery Application

Aplicación Flutter para explorar, descargar y guardar fondos de pantalla desde la API de Unsplash con funcionalidades de persistencia local, almacenamiento en caché offline y búsqueda avanzada.

---

## 📋 Requisitos Implementados

### 1. **Favoritos, Historial y Descargas** ✅
- **Ubicación**: `lib/presentation/providers/local_data_provider.dart`
- **Persistencia**: `lib/data/repositories/local_storage_repository.dart`
- **UI**: 
  - Favoritos: `lib/presentation/screens/saved_wallpapers_screen.dart`
  - Historial: `lib/presentation/screens/search_history_screen.dart`
  - Descargas: Drawer en `lib/presentation/screens/home_screen.dart`
- **Funcionalidad**: 
  - Los favoritos se guardan en SharedPreferences con clave `'favorites'`
  - Se pueden agregar/eliminar desde la pantalla de detalle (botón de corazón)
  - Los descargas se registran al descargar exitosamente (botón FAB)
  - Accesibles desde el drawer del lado izquierdo

### 2. **Historial como Búsquedas** ✅
- **Ubicación**: `lib/presentation/providers/local_data_provider.dart` (SearchHistoryNotifier)
- **Persistencia**: Clave `'search_history'` en SharedPreferences
- **Funcionalidad**:
  - Se registra cada búsqueda que el usuario envía
  - Se visualiza en `SearchHistoryScreen` con opción de eliminar individual y limpiar todo
  - Las búsquedas viejas permanecen disponibles para re-ejecutar

### 3. **Cache Offline** ✅
- **Ubicación**: `lib/data/repositories/wallpaper_repository_impl.dart`
- **Implementación**:
  - Primera página de resultados de búsqueda, autor y curated se cachean automáticamente
  - Claves de cache:
    - `'cached_wallpapers'` - Curated wallpapers
    - `'cached_search_${lang}_${query}'` - Búsquedas por término
    - `'cached_author_${username}'` - Búsquedas por autor
  - **Fallback**: Si la red falla, muestra el cache disponible
  - **Banner**: Cuando no hay conexión, aparece banner naranja indicando "Sin conexión. Se muestra el contenido en caché disponible."
  - **Red monitoring**: `lib/presentation/providers/network_provider.dart` con StreamProvider

### 3.1 **Manejo de errores (API / Offline)** ✅
- **Ubicación**: `lib/presentation/screens/error_screen.dart`
- **Qué hace**: Muestra una pantalla dedicada con una ilustración (gatito triste) y un botón `Reintentar` cuando hay errores críticos como falta de conexión o errores de la API (ej. 401 Unauthorized).
- **Detección 401**: `lib/presentation/widgets/wallpaper_grid.dart` detecta mensajes de error que contienen `401`, `unauthorized` o `client_id` y muestra la `ErrorScreen` con el mensaje localizado.
- **Assets**: Coloca tu ilustración en `assets/images/sad_cat.png`. Si no existe, la pantalla usa `assets/images/icon.png` como fallback.

### 4. **Recent Searches como Sugerencias** ✅
- **Ubicación**: `lib/presentation/screens/home_screen.dart` (líneas 60-85 aprox)
- **UI**: ActionChips debajo del SearchTextField
- **Funcionalidad**:
  - Muestra los últimas 5 búsquedas como chips clickeables
  - Al hacer click, rellena el buscador y ejecuta automáticamente la búsqueda
  - Si no hay búsquedas previas, los chips no aparecen

### 5. **Double-Tap Zoom Viewer** ✅
- **Ubicación**: `lib/presentation/screens/fullscreen_image_screen.dart`
- **Trigger**: Doble-tap en la imagen dentro de `detail_screen.dart`
- **Funcionalidades**:
  - Zoom mediante pinch (1x a 4x)
  - Arrastre lateral al estar zoomada
  - Doble-tap toggle entre zoom normal y 2.5x
  - Navegación suave con transición fade de 180ms
  - Hero animation para continuidad visual
   - Implementación técnica: usa `InteractiveViewer` con `TransformationController` en `lib/presentation/screens/fullscreen_image_screen.dart`.
     - `panEnabled: true`, `scaleEnabled: true`, `minScale: 1.0`, `maxScale: 4.0`.
     - `onDoubleTap` alterna entre escala 1x y 2.5x mediante `Matrix4.diagonal3Values(...)`.
     - La navegación desde `detail_screen.dart` usa `PageRouteBuilder` con `transitionDuration: Duration(milliseconds: 180)` para reducir la latencia percibida al doble-tap.

---

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** con separación de capas:

```
lib/
├── data/                 # Capa de Datos
│   ├── datasources/      # API clients (Unsplash)
│   ├── models/           # Modelos JSON serializables
│   └── repositories/     # Implementación de repositorios
│
├── domain/               # Capa de Lógica de Negocio
│   ├── entities/         # Entidades de dominio (Wallpaper)
│   └── repositories/     # Interfaces de repositorios
│
└── presentation/         # Capa de Presentación
    ├── providers/        # Riverpod providers (state management)
    ├── screens/          # Pantallas principales
    ├── widgets/          # Widgets reutilizables
    └── localization/     # i18n (Español/Inglés)
```

### Stack Tecnológico:
- **Framework**: Flutter 3.9.2
- **State Management**: flutter_riverpod 2.5.1
- **Persistencia**: shared_preferences 2.2.2
- **API HTTP**: dio 5.4.3
- **Caché de Imágenes**: cached_network_image 3.3.1
- **Monitoreo de Red**: connectivity_plus 6.0.3
- **Descarga de Imágenes**: image_gallery_saver_plus 4.0.1
- **Layout Masonry**: flutter_staggered_grid_view 0.7.0
- **i18n**: Localización manual con AppLocalizations

---

## 🎯 Flujos Principales

### Búsqueda y Favoritos
1. Usuario busca en home → Búsqueda se agrega a history
2. Wallpapers se cachean automáticamente (página 1)
3. Usuario puede hacer click en favoritos (corazón) en DetailScreen
4. Favoritos persistidos en SharedPreferences

### Offline
1. Si sin conexión, muestra cache de la última búsqueda/curated
2. Banner naranja indica estado offline
3. Galería descargada permanece accesible siempre

### Zoom
1. Usuario abre imagen → DetailScreen
2. Doble-tap → Navega a FullscreenImageScreen con Hero animation
3. Dentro: Pinch-to-zoom (1-4x) o doble-tap para toggle (1x/2.5x)
4. Atrás: Regresa con animación fade

---

## 📱 Pantallas Principales

| Pantalla | Ubicación | Descripción |
|----------|-----------|-------------|
| Home | `home_screen.dart` | Grid masonry de wallpapers, búsqueda, toggle tema |
| Detail | `detail_screen.dart` | Preview de imagen, favoritos, descargas, doble-tap |
| Fullscreen | `fullscreen_image_screen.dart` | Visor con zoom y pan |
| Favorites | `saved_wallpapers_screen.dart` | Grid de favoritos guardados |
| History | `search_history_screen.dart` | Lista de búsquedas previas |
| Downloads | `saved_wallpapers_screen.dart` | Grid de descargas |

---

## 🔧 Cómo Ejecutar

### Requisitos:
- Flutter 3.9.2+
- Dart 3.0+
- Clave API de Unsplash en `.env`

### Pasos:
```bash
# 1. Clonar y entrar al proyecto
cd galeriaapp

# 2. Instalar dependencias
flutter pub get

# 3. Crear archivo .env en la raíz del proyecto
echo "UNSPLASH_ACCESS_KEY=tu_api_key_aqui" > .env

# 4. Ejecutar en device/emulator
flutter run
```

### Estructura del .env:
```
UNSPLASH_ACCESS_KEY=your_api_key_here
```

---

## 📂 Archivos Clave por Requisito

| Requisito | Archivo Principal | Funciones Clave |
|-----------|-------------------|-----------------|
| Favoritos | `local_data_provider.dart` | `LocalDataNotifier.toggle()`, `favoritesProvider` |
| Historial | `search_history_screen.dart` | `SearchHistoryNotifier`, `searchHistoryProvider` |
| Descargas | `detail_screen.dart` | `_downloadImage()` → `downloadsProvider.notifier.add()` |
| Cache Offline | `wallpaper_repository_impl.dart` | `_saveCache()`, `_loadCache()`, fallback en `catch` |
| Recent Searches | `home_screen.dart` L65-L85 | ActionChips builder sobre searchHistoryProvider |
| Zoom | `fullscreen_image_screen.dart` | `InteractiveViewer`, `TransformationController`, Hero |

---

## 🌐 Localization

Soporta Español e Inglés. Cambiar en el toggle de language en el AppBar.

**Ubicación**: `lib/core/localization/app_localizations.dart`

Strings implementados:
- Favoritos/Desfavoritos
- Descargas exitosas/fallidas
- Banner offline
- Historial de búsquedas
- Labels de botones

---

## ⚡ Performance

- **Lazy Loading**: Paginación infinita en grid con scroll listener
- **Caché Multi-Nivel**: SharedPreferences + cached_network_image
- **Imagen Lightbox**: FastTransition de 180ms con Fade
- **Network Aware**: Solo intenta API si hay conexión

---

## 📝 Notas de Desarrollo

- Riverpod providers son reactivos; cambios en favoritos/downloads actualizan UI automáticamente
- Todas las lecturas de SharedPreferences ocurren en `main.dart` con inicialización async
- La API usa el patrón Repository con inyección de dependencias
- Los modelos JSON usan `jsonEncode/jsonDecode` para persistencia

---

## 📦 Versiones

- Flutter: 3.9.2
- Dart: 3.0+
- Material 3 habilitado

---

**Proyecto completado según requisitos académicos - Mayo 2026**
